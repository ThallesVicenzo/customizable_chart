import 'package:flutter/material.dart';
import '../chart_data_model.dart';
import '../../l10n/global_app_localizations.dart';
import '../../injector.dart';

class PromptService {
  static List<String> getSupportedPrompts() {
    final localizations = sl<GlobalAppLocalizations>().current;
    return [
      localizations.promptRedBold,
      localizations.promptBlueSales,
      localizations.promptMinimalGrid,
      localizations.promptOrangeTrending,
      localizations.promptPurpleThick,
    ];
  }

  static Map<String, dynamic>? processPrompt(String prompt) {
    final String normalizedPrompt = prompt.toLowerCase().trim();

    if (_matchesKeywords(normalizedPrompt, ['red', 'bold']) ||
        _matchesKeywords(normalizedPrompt, ['vermelho', 'grosso'])) {
      return {
        'description': 'Red and bold configuration',
        'config': {
          'lineColor': Colors.red,
          'gradientStartColor': Colors.red.withValues(alpha: 0.4),
          'gradientEndColor': Colors.red.withValues(alpha: 0.05),
          'lineWidth': 4.5,
          'showGrid': true,
          'showTooltip': true,
          'values': [
            15.0,
            35.0,
            25.0,
            60.0,
            45.0,
            80.0,
            65.0,
            90.0,
            75.0,
            95.0,
          ],
        },
      };
    }

    if (_matchesKeywords(normalizedPrompt, ['blue', 'sales']) ||
        _matchesKeywords(normalizedPrompt, ['sales', 'blue']) ||
        _matchesKeywords(normalizedPrompt, ['azul', 'vendas']) ||
        _matchesKeywords(normalizedPrompt, ['dados', 'vendas'])) {
      return {
        'description': 'Blue sales data visualization',
        'config': {
          'lineColor': Colors.blue.shade600,
          'gradientStartColor': Colors.blue.withValues(alpha: 0.3),
          'gradientEndColor': Colors.blue.withValues(alpha: 0.02),
          'lineWidth': 3.0,
          'showGrid': true,
          'showTooltip': true,
          'values': [
            20.0,
            45.0,
            35.0,
            55.0,
            70.0,
            60.0,
            85.0,
            75.0,
            90.0,
            80.0,
          ],
        },
      };
    }

    if (_matchesKeywords(normalizedPrompt, ['minimal', 'grid']) ||
        _matchesKeywords(normalizedPrompt, ['minimal', 'chart']) ||
        _matchesKeywords(normalizedPrompt, ['minimalista', 'grade']) ||
        _matchesKeywords(normalizedPrompt, ['gráfico', 'minimalista'])) {
      return {
        'description': 'Minimal chart with grid',
        'config': {
          'lineColor': Colors.grey.shade700,
          'gradientStartColor': Colors.grey.withValues(alpha: 0.1),
          'gradientEndColor': Colors.grey.withValues(alpha: 0.01),
          'lineWidth': 2.0,
          'showGrid': true,
          'showTooltip': false,
          'values': [
            30.0,
            35.0,
            32.0,
            38.0,
            42.0,
            40.0,
            45.0,
            48.0,
            50.0,
            52.0,
          ],
        },
      };
    }

    if (_matchesKeywords(normalizedPrompt, ['orange', 'bright']) ||
        _matchesKeywords(normalizedPrompt, ['orange', 'trending']) ||
        _matchesKeywords(normalizedPrompt, ['laranja', 'vibrante']) ||
        _matchesKeywords(normalizedPrompt, ['laranja', 'crescente'])) {
      return {
        'description': 'Bright orange trending view',
        'config': {
          'lineColor': Colors.deepOrange,
          'gradientStartColor': Colors.orange.withValues(alpha: 0.5),
          'gradientEndColor': Colors.orange.withValues(alpha: 0.03),
          'lineWidth': 3.5,
          'showGrid': false,
          'showTooltip': true,
          'values': [
            10.0,
            25.0,
            40.0,
            30.0,
            55.0,
            70.0,
            60.0,
            85.0,
            95.0,
            90.0,
          ],
        },
      };
    }

    if (_matchesKeywords(normalizedPrompt, ['purple', 'thick']) ||
        _matchesKeywords(normalizedPrompt, ['purple', 'theme']) ||
        _matchesKeywords(normalizedPrompt, ['roxo', 'grossas']) ||
        _matchesKeywords(normalizedPrompt, ['tema', 'roxo'])) {
      return {
        'description': 'Purple theme with thick lines',
        'config': {
          'lineColor': Colors.purple.shade600,
          'gradientStartColor': Colors.purple.withValues(alpha: 0.35),
          'gradientEndColor': Colors.purple.withValues(alpha: 0.02),
          'lineWidth': 5.0,
          'showGrid': true,
          'showTooltip': true,
          'values': [
            25.0,
            40.0,
            35.0,
            65.0,
            50.0,
            75.0,
            85.0,
            70.0,
            95.0,
            85.0,
          ],
        },
      };
    }

    return null;
  }

  static bool _matchesKeywords(String prompt, List<String> keywords) {
    return keywords.every((keyword) => prompt.contains(keyword));
  }

  static ChartDataModel configToChartData(Map<String, dynamic> config) {
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

  static List<String> getExamplePrompts() {
    return getSupportedPrompts();
  }
}
