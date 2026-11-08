import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/meter.dart';
import '../models/meter_reading.dart';
import '../repositories/reading_repository.dart';

enum _ChartMode { months, days }

class ConsumptionChart extends StatefulWidget {
  const ConsumptionChart({super.key, required this.meter});

  final Meter meter;

  @override
  State<ConsumptionChart> createState() => _ConsumptionChartState();
}

class _ConsumptionChartState extends State<ConsumptionChart> {
  final ReadingRepository _repository = ReadingRepository();

  List<MeterReading> _readings = [];
  bool _isLoading = true;
  String? _errorMessage;

  _ChartMode _mode = _ChartMode.months;
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  @override
  void didUpdateWidget(covariant ConsumptionChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.meter.id != widget.meter.id) {
      _readings = [];
      _selectedMonth = null;
      _loadReadings();
    }
  }

  Future<void> _loadReadings() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final readings = await _repository.getForMeter(widget.meter.id);

      if (!mounted) return;

      setState(() {
        _readings = readings;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  List<MeterReading> _getChronologicalReadings() {
    final result = List<MeterReading>.from(_readings);
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  Map<DateTime, double> _getMonthlyConsumption() {
    final readings = _getChronologicalReadings();
    final result = <DateTime, double>{};

    for (int i = 1; i < readings.length; i++) {
      final previous = readings[i - 1];
      final current = readings[i];

      final difference = current.value - previous.value;

      if (difference < 0) continue;

      final month = DateTime(current.date.year, current.date.month);

      result[month] = (result[month] ?? 0) + difference;
    }

    return result;
  }

  Map<DateTime, double> _getDailyConsumption(DateTime month) {
    final readings = _getChronologicalReadings();
    final result = <DateTime, double>{};

    for (int i = 1; i < readings.length; i++) {
      final previous = readings[i - 1];
      final current = readings[i];

      if (current.date.year != month.year ||
          current.date.month != month.month) {
        continue;
      }

      final difference = current.value - previous.value;

      if (difference < 0) continue;

      final day = DateTime(
        current.date.year,
        current.date.month,
        current.date.day,
      );

      result[day] = (result[day] ?? 0) + difference;
    }

    return result;
  }

  List<DateTime> _getSortedDates(Map<DateTime, double> values) {
    final dates = values.keys.toList();
    dates.sort((a, b) => a.compareTo(b));
    return dates;
  }

  String _monthName(int month) {
    const months = [
      'Янв',
      'Фев',
      'Мар',
      'Апр',
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
      'Ноя',
      'Дек',
    ];

    return months[month - 1];
  }

  String _formatMonth(DateTime date) {
    return '${_monthName(date.month)} ${date.year}';
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_readings.length < 2) {
      return _buildNoData();
    }

    final monthlyData = _getMonthlyConsumption();
    final availableMonths = _getSortedDates(monthlyData);

    if (availableMonths.isEmpty) {
      return _buildNoData();
    }

    final selectedMonth = availableMonths.contains(_selectedMonth)
        ? _selectedMonth!
        : availableMonths.last;

    final dailyData = _getDailyConsumption(selectedMonth);

    final dates = _mode == _ChartMode.months
        ? availableMonths
        : _getSortedDates(dailyData);

    final values = _mode == _ChartMode.months ? monthlyData : dailyData;

    if (dates.isEmpty) {
      return _buildNoData();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildModeSelector(),
        if (_mode == _ChartMode.days) ...[
          const SizedBox(height: 8),
          _buildMonthSelector(availableMonths, selectedMonth),
        ],
        const SizedBox(height: 12),
        Text(
          'Расход, ${widget.meter.type.unit}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        SizedBox(height: 155, child: _buildBarChart(dates, values)),
      ],
    );
  }

  Widget _buildModeSelector() {
    return SegmentedButton<_ChartMode>(
      segments: const [
        ButtonSegment(
          value: _ChartMode.months,
          label: Text('По месяцам'),
          icon: Icon(Icons.calendar_month, size: 16),
        ),
        ButtonSegment(
          value: _ChartMode.days,
          label: Text('По датам'),
          icon: Icon(Icons.today, size: 16),
        ),
      ],
      selected: {_mode},
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        setState(() {
          _mode = selection.first;
        });
      },
    );
  }

  Widget _buildMonthSelector(List<DateTime> months, DateTime selectedMonth) {
    return Row(
      children: [
        const Text(
          'Месяц:',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<DateTime>(
            value: selectedMonth,
            isExpanded: true,
            isDense: true,
            underline: const SizedBox.shrink(),
            items: months.map((month) {
              return DropdownMenuItem<DateTime>(
                value: month,
                child: Text(_formatMonth(month)),
              );
            }).toList(),
            onChanged: (month) {
              if (month == null) return;

              setState(() {
                _selectedMonth = month;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<DateTime> dates, Map<DateTime, double> values) {
    final chartValues = dates.map((date) => values[date] ?? 0).toList();

    final highestValue = chartValues.isEmpty
        ? 0.0
        : chartValues.reduce((a, b) => a > b ? a : b);

    final maxY = highestValue > 0 ? highestValue * 1.2 : 1.0;
    final interval = maxY / 4;

    final labels = dates.map((date) {
      if (_mode == _ChartMode.months) {
        return _monthName(date.month);
      }

      return date.day.toString();
    }).toList();

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
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
              reservedSize: 38,
              interval: interval,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();

                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }

                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(
                    labels[index],
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(chartValues.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: chartValues[index],
                color: widget.meter.type.color,
                width: _mode == _ChartMode.months ? 18 : 12,
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
              final label = labels[groupIndex];

              return BarTooltipItem(
                '$label\n${_formatNumber(rod.toY)} ${widget.meter.type.unit}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNoData() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_chart_outlined, size: 34, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Пока недостаточно данных для графика',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            'Добавьте ещё одно показание, чтобы рассчитать реальный расход.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          const Text('Не удалось загрузить данные графика'),
          TextButton(onPressed: _loadReadings, child: const Text('Повторить')),
        ],
      ),
    );
  }
}
