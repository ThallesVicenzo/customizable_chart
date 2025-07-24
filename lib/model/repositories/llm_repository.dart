import 'dart:convert';
import 'dart:developer';
import 'package:customizable_chart/model/services/client/client_http.dart';
import 'package:customizable_chart/model/services/environment.dart';
import 'package:customizable_chart/utils/llm_parser.dart';
import 'package:customizable_chart/l10n/global_app_localizations.dart';
import 'package:customizable_chart/injector.dart';
import 'package:dartz/dartz.dart';
import '../models/chart_data_model.dart';
import '../services/client/failures/llm_failure.dart';

abstract class LlmRepository {
  Future<Either<LlmFailure, Map<String, dynamic>>> processNaturalLanguagePrompt(
    String userInput,
  );
  ChartDataModel configToChartData(Map<String, dynamic> config);
}

class LLMRepositoryImplementation implements LlmRepository {
  final ClientHttp clientHttp;
  final EnvironmentService _environmentService;
  AppLocalizations? _localizations;

  LLMRepositoryImplementation(this.clientHttp)
    : _environmentService = sl<EnvironmentService>();

  AppLocalizations get _loc {
    _localizations ??= sl<GlobalAppLocalizations>().current;
    return _localizations!;
  }

  @override
  Future<Either<LlmFailure, Map<String, dynamic>>> processNaturalLanguagePrompt(
    String userInput,
  ) async {
    try {
      final token = await _environmentService.getAuthToken();
      final tokenInfo = await _environmentService.getTokenUsageInfo();

      if (token == null || token.isEmpty) {
        String message;

        log(
          'Authentication failed - token is null or empty',
          name: 'LLMRepository',
        );
        log('Token info: $tokenInfo', name: 'LLMRepository');

        if (tokenInfo['hasUserToken'] == false &&
            tokenInfo['canUseFallback'] == false) {
          message = _loc.freeTrialExpired(tokenInfo['totalFallbackUses']);
        } else if (tokenInfo['hasUserToken'] == false &&
            tokenInfo['canUseFallback'] == true) {
          final remaining = tokenInfo['remainingFallbackUses'];
          message = _loc.freeTrialActive(remaining);
        } else {
          message = _loc.authenticationError;
        }

        return Left(LlmAuthenticationFailure(message: message));
      }

      final response = await _callLLMAPI(userInput, token);
      if (response != null) {
        log('LLM API response received successfully', name: 'LLMRepository');
        final parsedResponse = LlmParser.parseStructuredResponse(response);
        if (parsedResponse != null) {
          // Check for invalid command error
          if (parsedResponse['error'] == 'INVALID_COMMAND') {
            log('Invalid command detected: $userInput', name: 'LLMRepository');
            return Left(
              LlmInvalidCommandFailure(message: _loc.promptErrorInvalidCommand),
            );
          }
          return Right(parsedResponse);
        } else {
          log('Failed to parse LLM response: $response', name: 'LLMRepository');
          return Left(
            LlmParsingFailure(message: _loc.unableToInterpretResponse),
          );
        }
      } else {
        log('LLM API returned null response', name: 'LLMRepository');
        return Left(LlmNetworkFailure(message: _loc.networkError));
      }
    } catch (e) {
      final errorMessage = e.toString();
      log(
        'Exception in processNaturalLanguagePrompt: $e',
        name: 'LLMRepository',
      );
      log('Error message: $errorMessage', name: 'LLMRepository');

      if (errorMessage.contains('insufficient_quota') ||
          errorMessage.contains('Too Many Requests') ||
          errorMessage.contains('429')) {
        log('API quota exceeded error detected', name: 'LLMRepository');
        return Left(LlmUnknownFailure(message: _loc.apiQuotaExceeded));
      }

      if (errorMessage.contains('model_not_found') ||
          errorMessage.contains('404')) {
        log('Model not found error detected', name: 'LLMRepository');
        return Left(LlmUnknownFailure(message: _loc.modelNotAvailable));
      }

      log('Unexpected error: $errorMessage', name: 'LLMRepository');
      return Left(
        LlmUnknownFailure(message: _loc.unexpectedError(e.toString())),
      );
    }
  }

  Future<String?> _callLLMAPI(String userInput, String token) async {
    log(
      'Making LLM API call for input: ${userInput.length > 100 ? "${userInput.substring(0, 100)}..." : userInput}',
      name: 'LLMRepository',
    );
    log(
      'Using token: ${token.isNotEmpty ? "Token present (${token.length} chars)" : "No token"}',
      name: 'LLMRepository',
    );

    final requestBody = {
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content':
              '''You are a chart configuration assistant. Parse user requests and return ONLY valid JSON with chart configuration.

IMPORTANT VALIDATION: Before processing any request, check if it's related to chart customization. If the user asks about anything NOT related to chart colors, appearance, line thickness, grid, tooltip, or data visualization, respond with this EXACT format:
{
  "success": false,
  "error": "INVALID_COMMAND",
  "message": "I can only help with chart customization (colors, line thickness, grid, tooltips). Please ask about chart appearance instead."
}

Valid chart-related requests include:
- Color changes: "make it blue", "red background", "green line"
- Line properties: "thicker line", "thin line", "bold line"
- Visual elements: "hide grid", "show tooltip", "remove grid"
- Data visualization: "sales data in blue", "show values"

Invalid requests (return INVALID_COMMAND error):
- General questions: "what is the weather?", "how are you?"
- Math/calculations: "what is 2+2?", "calculate this"
- Personal info: "what's your name?", "who made you?"
- Non-chart tasks: "write a story", "translate this", "explain quantum physics"

IMPORTANT: ALWAYS include ALL fields in your response, even if the user doesn't mention them. Use existing values or sensible defaults.

Response format for VALID requests (ALWAYS include ALL these fields):
{
  "success": true,
  "config": {
    "lineColor": "#0000FF",
    "gradientStartColor": "#0000FF", 
    "gradientEndColor": "#0000FF",
    "lineWidth": number,
    "showGrid": boolean,
    "showTooltip": boolean,
    "values": [10 numbers between 10-95],
    "description": "what was changed"
  }
}

COLOR RULES (Very Important - Follow these patterns exactly):

Pattern 1: LINE COLOR ONLY
- Triggers: "make it pink", "green line", "pink color", "turn blue"
- Action: Change ONLY lineColor, keep gradients subtle
- Example: "make it pink" → lineColor="#FFC0CB", gradientStartColor="#FFC0CB", gradientEndColor="#FFC0CB"
- Note: Gradients will be made transparent automatically by the code

Pattern 2: BACKGROUND/AREA COLOR  
- Triggers: "green background", "blue area", "pink background"
- Action: Change gradient colors, keep line contrasting
- Example: "blue background" → lineColor="#003D7A", gradientStartColor="#0066CC", gradientEndColor="#E6F3FF"

Pattern 3: EVERYTHING SAME COLOR
- Triggers: "everything green", "all green", "entire chart pink"
- Action: Apply same color to all elements
- Example: "everything green" → lineColor="#00FF00", gradientStartColor="#00FF00", gradientEndColor="#00FF00"

Pattern 4: SPECIFIC DATA/CONTENT
- Triggers: "sales data", "show sales data", "sales in green"
- Action: Treat as LINE COLOR change (Pattern 1)
- Example: "sales in green" → lineColor="#00FF00", gradientStartColor="#00FF00", gradientEndColor="#00FF00"

Default values:
- If user doesn't specify colors, use: lineColor="#0000FF", gradientStartColor="#0000FF33", gradientEndColor="#0000FF11"
- If user doesn't specify lineWidth, use: 2.5
- If user doesn't specify showGrid, use: true
- If user doesn't specify showTooltip, use: true
- If user doesn't specify values, use: [10, 25, 15, 40, 30, 55, 45, 70, 60, 85]

Color examples: red=#FF0000, blue=#0000FF, green=#00FF00, purple=#800080, orange=#FFA500, pink=#FFC0CB
Line width: 1.0 to 5.0''',
        },
        {
          'role': 'user',
          'content': '''Analyze this request: "$userInput"

Based on the request, determine what to change:
1. If it's about LINE color only (words like: "line", "make it", "color") → change lineColor only
2. If it's about BACKGROUND/AREA (words like: "background", "area", "backdrop") → change gradient colors
3. If it's about EVERYTHING (words like: "everything", "all", "entire chart") → change all colors

Apply the color rules from the system prompt.''',
        },
      ],
      'max_tokens': 500,
      'temperature': 0.3,
    };

    final response = await clientHttp.post(
      'https://api.openai.com/v1/chat/completions',
      data: jsonEncode(requestBody),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    log(
      'LLM API response status: ${response.statusCode}',
      name: 'LLMRepository',
    );
    log(
      'Response success: ${response.isStatusCodeSuccess}',
      name: 'LLMRepository',
    );

    if (response.isStatusCodeSuccess && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final content = data['choices']?[0]?['message']?['content'];
      log(
        'LLM response content length: ${content?.length ?? 0}',
        name: 'LLMRepository',
      );
      return content;
    }

    log(
      'LLM API call failed - status: ${response.statusCode}, data: ${response.data}',
      name: 'LLMRepository',
    );
    return null;
  }

  @override
  ChartDataModel configToChartData(Map<String, dynamic> config) {
    return LlmParser.configToChartData(config);
  }
}
