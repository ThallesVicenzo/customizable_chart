import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../model/models/chart_data_model.dart';

class LlmParser {
  static Map<String, dynamic>? parseStructuredResponse(String response) {
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

      // Check for error response first
      if (parsed['success'] == false && parsed['error'] == 'INVALID_COMMAND') {
        // Return a special marker for invalid command
        return {'error': 'INVALID_COMMAND'};
      }

      if (parsed['success'] == true && parsed['config'] != null) {
        return convertToFlutterConfig(parsed['config']);
      }
    } catch (e) {
      log('Error parsing LLM response: $e');
    }

    return null;
  }

  static Map<String, dynamic> convertToFlutterConfig(
    Map<String, dynamic> config,
  ) {
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

  static Color _hexToColor(String hex) {
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

  static Color _hexToColorWithOpacity(String hex, double opacity) {
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
}
