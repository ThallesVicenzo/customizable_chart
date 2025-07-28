import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../model/models/chart_data_model.dart';
import '../../l10n/global_app_localizations.dart';
import '../../injector.dart';

class CustomizableChart extends StatelessWidget {
  static const Key chartKey = Key('customizable_chart');
  final ChartDataModel chartData;

  const CustomizableChart({super.key, required this.chartData});

  List<FlSpot> _generateSpots(List<double> data) {
    return List.generate(
      data.length,
      (index) => FlSpot(index.toDouble(), data[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<double> sampleData = chartData.values;

    final double maxY =
        sampleData.isNotEmpty
            ? sampleData.reduce((a, b) => a > b ? a : b) * 1.2
            : 100;

    final double horizontalInterval = maxY / 4;

    return Container(
      key: chartKey,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: chartData.showGrid,
            drawVerticalLine: false,
            horizontalInterval: horizontalInterval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.3),
                strokeWidth: 0.8,
              );
            },
            drawHorizontalLine: true,
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      sl<GlobalAppLocalizations>().current.week(
                        value.toInt() + 1,
                      ),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: horizontalInterval,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0 ||
                      value.round() == horizontalInterval.round() ||
                      value.round() == (horizontalInterval * 2).round() ||
                      value.round() == (horizontalInterval * 3).round() ||
                      value.round() == maxY.round()) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: sampleData.length.toDouble() - 1,
          minY: 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            enabled: chartData.showTooltip,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor:
                  (touchedSpot) => chartData.lineColor.withValues(alpha: 0.8),
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final value = barSpot.y;
                  return LineTooltipItem(
                    '${value.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _generateSpots(sampleData),
              isCurved: true,
              color: chartData.lineColor,
              barWidth: chartData.lineWidth,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.2, 0.9],
                  colors: [
                    chartData.gradientStartColor,
                    chartData.gradientEndColor,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
