import 'package:flutter/material.dart';
import '../model/chart_data_model.dart';
import '../model/services/prompt_service.dart';

class ChartViewModel extends ChangeNotifier {
  ChartDataModel _chartData = ChartDataModel.defaultData();
  String? _lastPromptResult;
  final TextEditingController _promptController = TextEditingController();

  ChartDataModel get chartData => _chartData;
  String? get lastPromptResult => _lastPromptResult;
  TextEditingController get promptController => _promptController;

  void updateLineColor(Color color) {
    _chartData = _chartData.copyWith(lineColor: color);
    notifyListeners();
  }

  void updateGradientColors(Color startColor, Color endColor) {
    _chartData = _chartData.copyWith(
      gradientStartColor: startColor,
      gradientEndColor: endColor,
    );
    notifyListeners();
  }

  void updateLineWidth(double width) {
    _chartData = _chartData.copyWith(lineWidth: width);
    notifyListeners();
  }

  void toggleGrid() {
    _chartData = _chartData.copyWith(showGrid: !_chartData.showGrid);
    notifyListeners();
  }

  void toggleTooltip() {
    _chartData = _chartData.copyWith(showTooltip: !_chartData.showTooltip);
    notifyListeners();
  }

  void addRandomValue() {
    final List<double> newValues = List.from(_chartData.values);
    final double randomValue =
        (10 + (90 * (DateTime.now().millisecondsSinceEpoch % 100) / 100));
    newValues.add(randomValue);

    _chartData = _chartData.copyWith(values: newValues);
    notifyListeners();
  }

  void removeLastValue() {
    if (_chartData.values.length > 1) {
      final List<double> newValues = List.from(_chartData.values);
      newValues.removeLast();

      _chartData = _chartData.copyWith(values: newValues);
      notifyListeners();
    }
  }

  void resetData() {
    _chartData = ChartDataModel.defaultData();
    notifyListeners();
  }

  void setPresetColors(String preset) {
    switch (preset) {
      case 'blue':
        _chartData = _chartData.copyWith(
          lineColor: Colors.blue,
          gradientStartColor: Colors.blue.withValues(alpha: 0.2),
          gradientEndColor: Colors.blue.withValues(alpha: 0.01),
        );
        break;
      case 'red':
        _chartData = _chartData.copyWith(
          lineColor: Colors.red,
          gradientStartColor: Colors.red.withValues(alpha: 0.2),
          gradientEndColor: Colors.red.withValues(alpha: 0.01),
        );
        break;
      case 'green':
        _chartData = _chartData.copyWith(
          lineColor: Colors.green,
          gradientStartColor: Colors.green.withValues(alpha: 0.2),
          gradientEndColor: Colors.green.withValues(alpha: 0.01),
        );
        break;
      case 'purple':
        _chartData = _chartData.copyWith(
          lineColor: Colors.purple,
          gradientStartColor: Colors.purple.withValues(alpha: 0.2),
          gradientEndColor: Colors.purple.withValues(alpha: 0.01),
        );
        break;
      case 'orange':
        _chartData = _chartData.copyWith(
          lineColor: Colors.orange,
          gradientStartColor: Colors.orange.withValues(alpha: 0.2),
          gradientEndColor: Colors.orange.withValues(alpha: 0.01),
        );
        break;
    }
    notifyListeners();
  }

  bool processTextPrompt(String prompt) {
    final result = PromptService.processPrompt(prompt);
    if (result != null) {
      final config = result['config'] as Map<String, dynamic>;
      _chartData = PromptService.configToChartData(config);
      notifyListeners();
      return true;
    }
    return false;
  }

  List<String> getExamplePrompts() {
    return PromptService.getExamplePrompts();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void clearPromptResult() {
    _lastPromptResult = null;
    notifyListeners();
  }

  void clearPromptController() {
    _promptController.clear();
  }

  bool processTextPromptWithResult(String prompt, String errorMessage) {
    if (prompt.isEmpty) return false;

    final success = processTextPrompt(prompt);
    if (success) {
      _lastPromptResult = null;
      _promptController.clear();
    } else {
      _lastPromptResult = errorMessage;
      Future.delayed(const Duration(seconds: 3), () {
        clearPromptResult();
      });
    }
    notifyListeners();
    return success;
  }

  void useExamplePrompt(String prompt, String errorMessage) {
    _promptController.text = prompt;
    processTextPromptWithResult(prompt, errorMessage);
  }
}
