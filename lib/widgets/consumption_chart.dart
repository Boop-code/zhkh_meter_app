import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/meter.dart';

class ConsumptionChart extends StatelessWidget {
  const ConsumptionChart({super.key, required this.meter});

  final Meter meter;

  static const months = ['Май', 'Июн', 'Июл', 'Авг', 'Сен', 'Окт'];

  @override
  Widget build(BuildContext context) {
    final values = meter.monthlyConsumption;
    final maxValue = values.isEmpty
        ? 10.0
        : values.reduce((a, b) => a > b ? a : b);

    final chartMaxY = maxValue <= 0 ? 10.0 : maxValue * 1.25;
    final interval = chartMaxY / 4;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meter.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF18332E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Потребление за последние 6 месяцев, ${meter.type.unit}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 190,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: chartMaxY,
                  minX: 0,
                  maxX: 5,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: const Color(0xFFE9EFED),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();

                          if (index < 0 || index >= months.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              months[index],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) {
                        return spots.map((spot) {
                          final index = spot.x.toInt();
                          final month = index >= 0 && index < months.length
                              ? months[index]
                              : '';

                          return LineTooltipItem(
                            '$month\n${spot.y.toStringAsFixed(2)} ${meter.type.unit}',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < values.length; i++)
                          FlSpot(i.toDouble(), values[i]),
                      ],
                      isCurved: true,
                      curveSmoothness: 0.25,
                      color: meter.type.color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: meter.type.color,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: meter.type.color.withValues(alpha: 0.10),
                      ),
                    ),
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
