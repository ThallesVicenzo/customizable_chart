import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';
import 'package:customizable_chart/viewmodel/chart_viewmodel.dart';
import 'package:customizable_chart/model/models/chart_data_model.dart';
import 'package:customizable_chart/model/repositories/llm_repository.dart';

import 'chart_viewmodel_test.mocks.dart';

// Generate mocks
@GenerateMocks([LlmRepository])
void main() {
  group('ChartViewModel Tests', () {
    late ChartViewModel viewModel;
    late MockLlmRepository mockLlmRepository;
    late GetIt serviceLocator;

    setUpAll(() {
      serviceLocator = GetIt.instance;
    });

    setUp(() {
      mockLlmRepository = MockLlmRepository();
      serviceLocator.registerSingleton<LlmRepository>(mockLlmRepository);
      viewModel = ChartViewModel();
    });

    tearDown(() {
      serviceLocator.reset();
      viewModel.dispose();
    });

    group('Initial State', () {
      test('should have correct initial values', () {
        expect(viewModel.chartData, isA<ChartDataModel>());
        expect(viewModel.lastPromptResult, isNull);
        expect(viewModel.isProcessing, isFalse);
        expect(viewModel.promptController, isA<TextEditingController>());
        expect(viewModel.promptFocusNode, isA<FocusNode>());
      });

      test('should have default chart data', () {
        final chartData = viewModel.chartData;
        expect(chartData.values, isNotEmpty);
        expect(chartData.lineColor, isA<Color>());
        expect(chartData.lineWidth, greaterThan(0));
        expect(chartData.showGrid, isA<bool>());
        expect(chartData.showTooltip, isA<bool>());
      });
    });

    group('Chart Data Manipulation', () {
      test('updateLineColor should update line color', () {
        // Arrange
        const newColor = Colors.red;
        final initialColor = viewModel.chartData.lineColor;

        // Act
        viewModel.updateLineColor(newColor);

        // Assert
        expect(viewModel.chartData.lineColor, equals(newColor));
        expect(viewModel.chartData.lineColor, isNot(equals(initialColor)));
      });

      test('updateGradientColors should update gradient colors', () {
        // Arrange
        const startColor = Colors.blue;
        const endColor = Colors.lightBlue;

        // Act
        viewModel.updateGradientColors(startColor, endColor);

        // Assert
        expect(viewModel.chartData.gradientStartColor, equals(startColor));
        expect(viewModel.chartData.gradientEndColor, equals(endColor));
      });

      test('updateLineWidth should update line width', () {
        // Arrange
        const newWidth = 5.0;
        final initialWidth = viewModel.chartData.lineWidth;

        // Act
        viewModel.updateLineWidth(newWidth);

        // Assert
        expect(viewModel.chartData.lineWidth, equals(newWidth));
        expect(viewModel.chartData.lineWidth, isNot(equals(initialWidth)));
      });

      test('toggleGrid should toggle grid visibility', () {
        // Arrange
        final initialGridState = viewModel.chartData.showGrid;

        // Act
        viewModel.toggleGrid();

        // Assert
        expect(viewModel.chartData.showGrid, equals(!initialGridState));
      });

      test('toggleTooltip should toggle tooltip visibility', () {
        // Arrange
        final initialTooltipState = viewModel.chartData.showTooltip;

        // Act
        viewModel.toggleTooltip();

        // Assert
        expect(viewModel.chartData.showTooltip, equals(!initialTooltipState));
      });
    });

    group('Data Points Management', () {
      test('addRandomValue should add a new value to chart data', () {
        // Arrange
        final initialLength = viewModel.chartData.values.length;

        // Act
        viewModel.addRandomValue();

        // Assert
        expect(viewModel.chartData.values.length, equals(initialLength + 1));
        expect(viewModel.chartData.values.last, greaterThanOrEqualTo(10.0));
        expect(viewModel.chartData.values.last, lessThanOrEqualTo(100.0));
      });

      test('removeLastValue should remove the last value', () {
        // Arrange
        viewModel.addRandomValue(); // Add a value first
        final initialLength = viewModel.chartData.values.length;

        // Act
        viewModel.removeLastValue();

        // Assert
        expect(viewModel.chartData.values.length, equals(initialLength - 1));
      });

      test('removeLastValue should not remove if only one value remains', () {
        // Arrange - Reset to ensure we have default data
        viewModel.resetData();
        // Remove all but one value
        while (viewModel.chartData.values.length > 1) {
          viewModel.removeLastValue();
        }
        final finalLength = viewModel.chartData.values.length;

        // Act - Try to remove the last remaining value
        viewModel.removeLastValue();

        // Assert - Should still have at least one value
        expect(viewModel.chartData.values.length, equals(finalLength));
        expect(viewModel.chartData.values.length, greaterThanOrEqualTo(1));
      });

      test('resetData should restore default chart data', () {
        // Arrange - Modify the chart data
        viewModel.updateLineColor(Colors.red);
        viewModel.updateLineWidth(10.0);
        viewModel.addRandomValue();

        // Act
        viewModel.resetData();

        // Assert
        final defaultData = ChartDataModel.defaultData();
        expect(viewModel.chartData.lineColor, equals(defaultData.lineColor));
        expect(viewModel.chartData.lineWidth, equals(defaultData.lineWidth));
        expect(
          viewModel.chartData.values.length,
          equals(defaultData.values.length),
        );
      });
    });

    group('Simulated Prompt Processing', () {
      test('should process "vendas azul" prompt correctly', () {
        // Act
        viewModel.processSimulatedPrompt('vendas azul');

        // Assert
        expect(viewModel.chartData.lineColor, equals(Colors.blue.shade600));
        expect(viewModel.chartData.lineWidth, equals(3.0));
        expect(viewModel.chartData.showGrid, isTrue);
        expect(viewModel.chartData.showTooltip, isTrue);
        expect(viewModel.chartData.values.length, equals(10));
      });

      test('should handle unrecognized prompts without changes', () {
        // Arrange
        final initialData = viewModel.chartData;

        // Act
        viewModel.processSimulatedPrompt('unrecognized prompt');

        // Assert
        expect(viewModel.chartData.lineColor, equals(initialData.lineColor));
        expect(viewModel.chartData.lineWidth, equals(initialData.lineWidth));
        expect(
          viewModel.chartData.values.length,
          equals(initialData.values.length),
        );
      });
    });

    group('Prompt Controller Management', () {
      test('should clear prompt controller', () {
        // Arrange
        viewModel.promptController.text = 'some text';

        // Act
        viewModel.clearPromptController();

        // Assert
        expect(viewModel.promptController.text, isEmpty);
      });

      test('should clear prompt result', () {
        // Act
        viewModel.clearPromptResult();

        // Assert
        expect(viewModel.lastPromptResult, isNull);
      });
    });
  });
}
