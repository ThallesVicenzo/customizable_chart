import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customizable_chart/model/models/chart_data_model.dart';

void main() {
  group('ChartDataModel Tests', () {
    test('should create ChartDataModel with required parameters', () {
      // Arrange
      final values = [1.0, 2.0, 3.0, 4.0, 5.0];
      const lineColor = Colors.red;
      final gradientStartColor = Colors.red.withValues(alpha: 0.3);
      final gradientEndColor = Colors.red.withValues(alpha: 0.1);

      // Act
      final chartData = ChartDataModel(
        values: values,
        lineColor: lineColor,
        gradientStartColor: gradientStartColor,
        gradientEndColor: gradientEndColor,
      );

      // Assert
      expect(chartData.values, equals(values));
      expect(chartData.lineColor, equals(lineColor));
      expect(chartData.gradientStartColor, equals(gradientStartColor));
      expect(chartData.gradientEndColor, equals(gradientEndColor));
      expect(chartData.lineWidth, equals(2.5)); // default value
      expect(chartData.showGrid, isTrue); // default value
      expect(chartData.showTooltip, isTrue); // default value
    });

    test('should create ChartDataModel with custom optional parameters', () {
      // Arrange
      final values = [1.0, 2.0, 3.0];
      const lineColor = Colors.green;
      final gradientStartColor = Colors.green.withValues(alpha: 0.2);
      final gradientEndColor = Colors.green.withValues(alpha: 0.05);
      const lineWidth = 4.0;
      const showGrid = false;
      const showTooltip = false;

      // Act
      final chartData = ChartDataModel(
        values: values,
        lineColor: lineColor,
        gradientStartColor: gradientStartColor,
        gradientEndColor: gradientEndColor,
        lineWidth: lineWidth,
        showGrid: showGrid,
        showTooltip: showTooltip,
      );

      // Assert
      expect(chartData.values, equals(values));
      expect(chartData.lineColor, equals(lineColor));
      expect(chartData.gradientStartColor, equals(gradientStartColor));
      expect(chartData.gradientEndColor, equals(gradientEndColor));
      expect(chartData.lineWidth, equals(lineWidth));
      expect(chartData.showGrid, equals(showGrid));
      expect(chartData.showTooltip, equals(showTooltip));
    });

    test('should create default ChartDataModel correctly', () {
      // Act
      final defaultChart = ChartDataModel.defaultData();

      // Assert
      expect(
        defaultChart.values,
        equals([10, 25, 15, 40, 30, 55, 45, 70, 60, 85]),
      );
      expect(defaultChart.lineColor, equals(Colors.blue));
      expect(
        defaultChart.gradientStartColor,
        equals(Colors.blue.withValues(alpha: 0.2)),
      );
      expect(
        defaultChart.gradientEndColor,
        equals(Colors.blue.withValues(alpha: 0.01)),
      );
      expect(defaultChart.lineWidth, equals(2.5));
      expect(defaultChart.showGrid, isTrue);
      expect(defaultChart.showTooltip, isTrue);
    });

    group('copyWith method', () {
      late ChartDataModel originalChart;

      setUp(() {
        originalChart = ChartDataModel(
          values: [1.0, 2.0, 3.0],
          lineColor: Colors.blue,
          gradientStartColor: Colors.blue.withValues(alpha: 0.3),
          gradientEndColor: Colors.blue.withValues(alpha: 0.1),
          lineWidth: 2.0,
          showGrid: true,
          showTooltip: true,
        );
      });

      test('should return identical chart when no parameters provided', () {
        // Act
        final copiedChart = originalChart.copyWith();

        // Assert
        expect(copiedChart.values, equals(originalChart.values));
        expect(copiedChart.lineColor, equals(originalChart.lineColor));
        expect(
          copiedChart.gradientStartColor,
          equals(originalChart.gradientStartColor),
        );
        expect(
          copiedChart.gradientEndColor,
          equals(originalChart.gradientEndColor),
        );
        expect(copiedChart.lineWidth, equals(originalChart.lineWidth));
        expect(copiedChart.showGrid, equals(originalChart.showGrid));
        expect(copiedChart.showTooltip, equals(originalChart.showTooltip));
      });

      test('should update only values when provided', () {
        // Arrange
        final newValues = [10.0, 20.0, 30.0, 40.0];

        // Act
        final copiedChart = originalChart.copyWith(values: newValues);

        // Assert
        expect(copiedChart.values, equals(newValues));
        expect(copiedChart.lineColor, equals(originalChart.lineColor));
        expect(
          copiedChart.gradientStartColor,
          equals(originalChart.gradientStartColor),
        );
        expect(
          copiedChart.gradientEndColor,
          equals(originalChart.gradientEndColor),
        );
        expect(copiedChart.lineWidth, equals(originalChart.lineWidth));
        expect(copiedChart.showGrid, equals(originalChart.showGrid));
        expect(copiedChart.showTooltip, equals(originalChart.showTooltip));
      });

      test('should update only lineColor when provided', () {
        // Arrange
        const newLineColor = Colors.red;

        // Act
        final copiedChart = originalChart.copyWith(lineColor: newLineColor);

        // Assert
        expect(copiedChart.values, equals(originalChart.values));
        expect(copiedChart.lineColor, equals(newLineColor));
        expect(
          copiedChart.gradientStartColor,
          equals(originalChart.gradientStartColor),
        );
        expect(
          copiedChart.gradientEndColor,
          equals(originalChart.gradientEndColor),
        );
        expect(copiedChart.lineWidth, equals(originalChart.lineWidth));
        expect(copiedChart.showGrid, equals(originalChart.showGrid));
        expect(copiedChart.showTooltip, equals(originalChart.showTooltip));
      });

      test('should update gradient colors when provided', () {
        // Arrange
        final newGradientStart = Colors.green.withValues(alpha: 0.4);
        final newGradientEnd = Colors.green.withValues(alpha: 0.05);

        // Act
        final copiedChart = originalChart.copyWith(
          gradientStartColor: newGradientStart,
          gradientEndColor: newGradientEnd,
        );

        // Assert
        expect(copiedChart.values, equals(originalChart.values));
        expect(copiedChart.lineColor, equals(originalChart.lineColor));
        expect(copiedChart.gradientStartColor, equals(newGradientStart));
        expect(copiedChart.gradientEndColor, equals(newGradientEnd));
        expect(copiedChart.lineWidth, equals(originalChart.lineWidth));
        expect(copiedChart.showGrid, equals(originalChart.showGrid));
        expect(copiedChart.showTooltip, equals(originalChart.showTooltip));
      });

      test('should update lineWidth when provided', () {
        // Arrange
        const newLineWidth = 5.0;

        // Act
        final copiedChart = originalChart.copyWith(lineWidth: newLineWidth);

        // Assert
        expect(copiedChart.values, equals(originalChart.values));
        expect(copiedChart.lineColor, equals(originalChart.lineColor));
        expect(
          copiedChart.gradientStartColor,
          equals(originalChart.gradientStartColor),
        );
        expect(
          copiedChart.gradientEndColor,
          equals(originalChart.gradientEndColor),
        );
        expect(copiedChart.lineWidth, equals(newLineWidth));
        expect(copiedChart.showGrid, equals(originalChart.showGrid));
        expect(copiedChart.showTooltip, equals(originalChart.showTooltip));
      });

      test('should update boolean flags when provided', () {
        // Act
        final copiedChart = originalChart.copyWith(
          showGrid: false,
          showTooltip: false,
        );

        // Assert
        expect(copiedChart.values, equals(originalChart.values));
        expect(copiedChart.lineColor, equals(originalChart.lineColor));
        expect(
          copiedChart.gradientStartColor,
          equals(originalChart.gradientStartColor),
        );
        expect(
          copiedChart.gradientEndColor,
          equals(originalChart.gradientEndColor),
        );
        expect(copiedChart.lineWidth, equals(originalChart.lineWidth));
        expect(copiedChart.showGrid, isFalse);
        expect(copiedChart.showTooltip, isFalse);
      });

      test('should update multiple properties at once', () {
        // Arrange
        final newValues = [100.0, 200.0];
        const newLineColor = Colors.purple;
        const newLineWidth = 3.5;
        const newShowGrid = false;

        // Act
        final copiedChart = originalChart.copyWith(
          values: newValues,
          lineColor: newLineColor,
          lineWidth: newLineWidth,
          showGrid: newShowGrid,
        );

        // Assert
        expect(copiedChart.values, equals(newValues));
        expect(copiedChart.lineColor, equals(newLineColor));
        expect(
          copiedChart.gradientStartColor,
          equals(originalChart.gradientStartColor),
        );
        expect(
          copiedChart.gradientEndColor,
          equals(originalChart.gradientEndColor),
        );
        expect(copiedChart.lineWidth, equals(newLineWidth));
        expect(copiedChart.showGrid, equals(newShowGrid));
        expect(copiedChart.showTooltip, equals(originalChart.showTooltip));
      });
    });

    group('Edge cases', () {
      test('should handle empty values list', () {
        // Act
        final chartData = ChartDataModel(
          values: [],
          lineColor: Colors.blue,
          gradientStartColor: Colors.blue.withValues(alpha: 0.2),
          gradientEndColor: Colors.blue.withValues(alpha: 0.01),
        );

        // Assert
        expect(chartData.values, isEmpty);
        expect(chartData.lineColor, equals(Colors.blue));
      });

      test('should handle single value in list', () {
        // Act
        final chartData = ChartDataModel(
          values: [42.0],
          lineColor: Colors.orange,
          gradientStartColor: Colors.orange.withValues(alpha: 0.3),
          gradientEndColor: Colors.orange.withValues(alpha: 0.05),
        );

        // Assert
        expect(chartData.values, equals([42.0]));
        expect(chartData.values.length, equals(1));
      });

      test('should handle zero lineWidth', () {
        // Act
        final chartData = ChartDataModel(
          values: [1.0, 2.0, 3.0],
          lineColor: Colors.red,
          gradientStartColor: Colors.red.withValues(alpha: 0.2),
          gradientEndColor: Colors.red.withValues(alpha: 0.01),
          lineWidth: 0.0,
        );

        // Assert
        expect(chartData.lineWidth, equals(0.0));
      });

      test('should handle negative values in chart data', () {
        // Act
        final chartData = ChartDataModel(
          values: [-10.0, -5.0, 0.0, 5.0, 10.0],
          lineColor: Colors.black,
          gradientStartColor: Colors.black.withValues(alpha: 0.2),
          gradientEndColor: Colors.black.withValues(alpha: 0.01),
        );

        // Assert
        expect(chartData.values, equals([-10.0, -5.0, 0.0, 5.0, 10.0]));
        expect(chartData.values.contains(-10.0), isTrue);
        expect(chartData.values.contains(0.0), isTrue);
      });
    });
  });
}
