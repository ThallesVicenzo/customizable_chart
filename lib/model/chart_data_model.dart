import 'package:flutter/material.dart';

class ChartDataModel {
  final List<double> values;
  final Color lineColor;
  final Color gradientStartColor;
  final Color gradientEndColor;
  final double lineWidth;
  final bool showGrid;
  final bool showTooltip;

  ChartDataModel({
    required this.values,
    required this.lineColor,
    required this.gradientStartColor,
    required this.gradientEndColor,
    this.lineWidth = 2.5,
    this.showGrid = true,
    this.showTooltip = true,
  });

  ChartDataModel copyWith({
    List<double>? values,
    Color? lineColor,
    Color? gradientStartColor,
    Color? gradientEndColor,
    double? lineWidth,
    bool? showGrid,
    bool? showTooltip,
  }) {
    return ChartDataModel(
      values: values ?? this.values,
      lineColor: lineColor ?? this.lineColor,
      gradientStartColor: gradientStartColor ?? this.gradientStartColor,
      gradientEndColor: gradientEndColor ?? this.gradientEndColor,
      lineWidth: lineWidth ?? this.lineWidth,
      showGrid: showGrid ?? this.showGrid,
      showTooltip: showTooltip ?? this.showTooltip,
    );
  }

  static ChartDataModel defaultData() {
    return ChartDataModel(
      values: [10, 25, 15, 40, 30, 55, 45, 70, 60, 85],
      lineColor: Colors.blue,
      gradientStartColor: Colors.blue.withValues(alpha: 0.2),
      gradientEndColor: Colors.blue.withValues(alpha: 0.01),
    );
  }
}
