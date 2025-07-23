import 'package:flutter/material.dart';
import '../model/models/chart_data_model.dart';
import '../model/repositories/llm_repository.dart';
import '../model/failures/llm_failure.dart';
import '../injector.dart';

class ChartViewModel extends ChangeNotifier {
  ChartDataModel _chartData = ChartDataModel.defaultData();
  String? _lastPromptResult;
  final TextEditingController _promptController = TextEditingController();
  bool _isProcessing = false;
  final FocusNode promptFocusNode = FocusNode();

  ChartDataModel get chartData => _chartData;
  String? get lastPromptResult => _lastPromptResult;
  TextEditingController get promptController => _promptController;
  bool get isProcessing => _isProcessing;

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

  void processSimulatedPrompt(String prompt) {
    final normalizedPrompt = prompt.toLowerCase().trim();

    if (normalizedPrompt.contains('vendas') &&
        normalizedPrompt.contains('azul')) {
      _chartData = _chartData.copyWith(
        lineColor: Colors.blue.shade600,
        gradientStartColor: Colors.blue.withValues(alpha: 0.3),
        gradientEndColor: Colors.blue.withValues(alpha: 0.02),
        lineWidth: 3.0,
        showGrid: true,
        showTooltip: true,
        values: [20.0, 45.0, 35.0, 55.0, 70.0, 60.0, 85.0, 75.0, 90.0, 80.0],
      );
    } else if (normalizedPrompt.contains('vermelho') &&
        normalizedPrompt.contains('grosso')) {
      _chartData = _chartData.copyWith(
        lineColor: Colors.red,
        gradientStartColor: Colors.red.withValues(alpha: 0.4),
        gradientEndColor: Colors.red.withValues(alpha: 0.05),
        lineWidth: 4.5,
        showGrid: true,
        showTooltip: true,
        values: [15.0, 35.0, 25.0, 60.0, 45.0, 80.0, 65.0, 90.0, 75.0, 95.0],
      );
    } else if (normalizedPrompt.contains('minimalista') &&
        normalizedPrompt.contains('grade')) {
      _chartData = _chartData.copyWith(
        lineColor: Colors.grey.shade700,
        gradientStartColor: Colors.grey.withValues(alpha: 0.1),
        gradientEndColor: Colors.grey.withValues(alpha: 0.01),
        lineWidth: 2.0,
        showGrid: true,
        showTooltip: false,
        values: [30.0, 35.0, 32.0, 38.0, 42.0, 40.0, 45.0, 48.0, 50.0, 52.0],
      );
    } else if (normalizedPrompt.contains('laranja') &&
        normalizedPrompt.contains('vibrante')) {
      _chartData = _chartData.copyWith(
        lineColor: Colors.deepOrange,
        gradientStartColor: Colors.orange.withValues(alpha: 0.5),
        gradientEndColor: Colors.orange.withValues(alpha: 0.03),
        lineWidth: 3.5,
        showGrid: false,
        showTooltip: true,
        values: [10.0, 25.0, 40.0, 30.0, 55.0, 70.0, 60.0, 85.0, 95.0, 90.0],
      );
    } else if (normalizedPrompt.contains('roxo') &&
        normalizedPrompt.contains('grossas')) {
      _chartData = _chartData.copyWith(
        lineColor: Colors.purple.shade600,
        gradientStartColor: Colors.purple.withValues(alpha: 0.35),
        gradientEndColor: Colors.purple.withValues(alpha: 0.02),
        lineWidth: 5.0,
        showGrid: true,
        showTooltip: true,
        values: [25.0, 40.0, 35.0, 65.0, 50.0, 75.0, 85.0, 70.0, 95.0, 85.0],
      );
    }

    notifyListeners();
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

  Future<bool> processTextPromptWithResult(
    String prompt,
    String errorMessage,
  ) async {
    if (prompt.isEmpty) return false;

    final success = await processNaturalLanguagePrompt(prompt, errorMessage);
    return success;
  }

  Future<bool> processNaturalLanguagePrompt(
    String prompt,
    String errorMessage,
  ) async {
    if (prompt.isEmpty) return false;

    final repository = sl<LlmRepository>();
    final result = await repository.processNaturalLanguagePrompt(prompt);

    return result.fold(
      (failure) {
        String failureMessage = errorMessage;
        if (failure is LlmAuthenticationFailure) {
          failureMessage = failure.message;
        } else if (failure is LlmNetworkFailure) {
          failureMessage = failure.message;
        } else if (failure is LlmParsingFailure) {
          failureMessage = failure.message;
        } else if (failure is LlmUnknownFailure) {
          failureMessage = failure.message;
        }

        _lastPromptResult = failureMessage;
        Future.delayed(const Duration(seconds: 5), () {
          clearPromptResult();
        });
        notifyListeners();
        return false;
      },
      (data) {
        _chartData = repository.configToChartData(data);
        _lastPromptResult = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> processPrompt(String errorMessage) async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    _isProcessing = true;
    notifyListeners();

    final success = await processNaturalLanguagePrompt(prompt, errorMessage);

    _isProcessing = false;
    notifyListeners();

    if (success) {
      _promptController.clear();
    }

    if (isProcessing && lastPromptResult == null) {
      promptFocusNode.unfocus();
    }
  }
}
