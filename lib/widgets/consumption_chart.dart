
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/meter.dart';

class ConsumptionChart extends StatelessWidget {
  const ConsumptionChart({
    super.key,
    required this.meter,
  });

  final Meter meter;

  @override
  Widget build(BuildContext context) {
    final values = meter.monthlyConsumption;
    final maxValue = values.isEmpty
        ? 10.0
        : values.reduce((a, b) => a > b ? a : b) * 1.2;

    final chartColor = meter.type.color;

    const months = [
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 170,
          child: BarChart(
            BarChartData(
              maxY: maxValue > 0 ? maxValue : 10,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval:
                maxValue > 0 ? maxValue / 4 : 2.5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withValues(alpha: 0.15),
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
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();

                      if (index < 0 || index >= months.length) {
                        return const SizedBox.shrink();
                      }

                      return SideTitleWidget(
                        meta: meta,
                        space: 6,
                        child: Text(
                          months[index],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(values.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: values[index],
                      color: chartColor,
                      width: 18,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                    ),
                  ],
                );
              }),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final unit = meter.type.unit;

                    return BarTooltipItem(
                      '${rod.toY.toStringAsFixed(2)} $unit',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
