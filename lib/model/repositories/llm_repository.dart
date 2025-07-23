import 'dart:convert';
import 'package:customizable_chart/model/services/client/client_http.dart';
import 'package:customizable_chart/model/services/environment.dart';
import 'package:flutter/material.dart';
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

  LLMRepositoryImplementation(this.clientHttp);

  @override
  Future<Either<LlmFailure, Map<String, dynamic>>> processNaturalLanguagePrompt(
    String userInput,
  ) async {
    try {
      final token = await authToken;
      if (token == null || token.isEmpty) {
        return const Left(
          LlmAuthenticationFailure(
            message:
                'To use the AI functionality, you need to configure your OpenAI key:\n\n'
                '1. Access app settings\n'
                '2. Tap "Configure OpenAI API"\n'
                '3. Enter your API key\n\n'
                'To get a free key:\n'
                '• Visit: https://platform.openai.com/api-keys\n'
                '• Create an account (if you don\'t have one)\n'
                '• Generate a new API Key\n\n'
                'OpenAI offers free credits for new users!',
          ),
        );
      }

      final response = await _callLLMAPI(userInput);
      if (response != null) {
        final parsedResponse = _parseStructuredResponse(response);
        if (parsedResponse != null) {
          return Right(parsedResponse);
        } else {
          return const Left(
            LlmParsingFailure(
              message:
                  'Unable to interpret AI response. Try rephrasing your request.',
            ),
          );
        }
      } else {
        return const Left(
          LlmNetworkFailure(
            message:
                'Error connecting to OpenAI API. Check your internet connection and try again.',
          ),
        );
      }
    } catch (e) {
      final errorMessage = e.toString();

      // Specific handling for quota exceeded error
      if (errorMessage.contains('insufficient_quota') ||
          errorMessage.contains('Too Many Requests') ||
          errorMessage.contains('429')) {
        return const Left(
          LlmUnknownFailure(
            message:
                'OpenAI API quota exceeded. To continue using AI:\n\n'
                '1. Visit: https://platform.openai.com/settings/organization/billing\n'
                '2. Add a payment method\n'
                '3. Or wait for the free quota reset\n\n'
                'Alternatively, you can use the example buttons that work without AI.',
          ),
        );
      }

      if (errorMessage.contains('model_not_found') ||
          errorMessage.contains('404')) {
        return const Left(
          LlmUnknownFailure(
            message:
                'AI model not available. Your OpenAI account may not have access to GPT-3.5.\n\n'
                'Try using the example buttons that work without AI.',
          ),
        );
      }

      return Left(
        LlmUnknownFailure(
          message:
              'Unexpected error: ${e.toString()}\n\n'
              'Check your OpenAI API key and try again.',
        ),
      );
    }
  }

  Future<String?> _callLLMAPI(String userInput) async {
    final token = await authToken;

    final requestBody = {
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content':
              '''You are a chart configuration assistant. Parse user requests and return ONLY valid JSON with chart configuration.

IMPORTANT: ALWAYS include ALL fields in your response, even if the user doesn't mention them. Use existing values or sensible defaults.

Response format (ALWAYS include ALL these fields):
{
  "success": true,
  "config": {
    "lineColor": "#RRGGBB",
    "gradientStartColor": "#RRGGBB", 
    "gradientEndColor": "#RRGGBB",
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
      endpoint,
      data: jsonEncode(requestBody),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.isStatusCodeSuccess && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      return data['choices']?[0]?['message']?['content'];
    }

    return null;
  }

  Map<String, dynamic>? _parseStructuredResponse(String response) {
    String cleanResponse = response.trim();
    if (cleanResponse.startsWith('```json')) {
      cleanResponse = cleanResponse.replaceFirst('```json', '');
    }
    if (cleanResponse.endsWith('```')) {
      cleanResponse = cleanResponse.substring(
        0,
        cleanResponse.lastIndexOf('```'),
      );
    }

    try {
      final parsed = jsonDecode(cleanResponse.trim());

      if (parsed['success'] == true && parsed['config'] != null) {
        return convertToFlutterConfig(parsed['config']);
      }
    } catch (e) {
      // Silently handle JSON parsing errors
    }

    return null;
  }

  Map<String, dynamic> convertToFlutterConfig(Map<String, dynamic> config) {
    final defaultValues = [
      10.0,
      25.0,
      15.0,
      40.0,
      30.0,
      55.0,
      45.0,
      70.0,
      60.0,
      85.0,
    ];
    final defaultLineColor = '#0000FF';
    final defaultGradientStart = '#0000FF';
    final defaultGradientEnd = '#0000FF';

    final lineColor = config['lineColor'] ?? defaultLineColor;
    String gradientStart = config['gradientStartColor'] ?? defaultGradientStart;
    String gradientEnd = config['gradientEndColor'] ?? defaultGradientEnd;

    if (config['lineColor'] != null &&
        (config['gradientStartColor'] == null ||
            config['gradientEndColor'] == null)) {
      gradientStart = lineColor;
      gradientEnd = lineColor;
    }

    return {
      'lineColor': _hexToColor(lineColor),
      'gradientStartColor': _hexToColorWithOpacity(gradientStart, 0.2),
      'gradientEndColor': _hexToColorWithOpacity(gradientEnd, 0.05),
      'lineWidth':
          config['lineWidth'] != null
              ? (config['lineWidth'] as num).toDouble()
              : 2.5,
      'showGrid': config['showGrid'] ?? true,
      'showTooltip': config['showTooltip'] ?? true,
      'values':
          config['values'] != null
              ? (config['values'] as List)
                  .map((v) => (v as num).toDouble())
                  .toList()
              : defaultValues,
      'description': config['description'] ?? 'Configuration updated',
    };
  }

  Color _hexToColor(String hex) {
    try {
      hex = hex.replaceFirst('#', '');
      if (hex.length != 6) {
        hex = '0000FF';
      }
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFF0000FF);
    }
  }

  Color _hexToColorWithOpacity(String hex, double opacity) {
    try {
      hex = hex.replaceFirst('#', '');
      if (hex.length != 6) {
        hex = '0000FF';
      }

      final alpha = (opacity * 255).round().toRadixString(16).padLeft(2, '0');
      return Color(int.parse('$alpha$hex', radix: 16));
    } catch (e) {
      final alpha = (opacity * 255).round().toRadixString(16).padLeft(2, '0');
      return Color(int.parse('${alpha}0000FF', radix: 16));
    }
  }

  @override
  ChartDataModel configToChartData(Map<String, dynamic> config) {
    return ChartDataModel(
      values: List<double>.from(config['values']),
      lineColor: config['lineColor'] as Color,
      gradientStartColor: config['gradientStartColor'] as Color,
      gradientEndColor: config['gradientEndColor'] as Color,
      lineWidth: config['lineWidth'].toDouble(),
      showGrid: config['showGrid'],
      showTooltip: config['showTooltip'],
    );
  }
}
