import 'package:flutter/material.dart';

import '../models/meter.dart';
import '../widgets/consumption_chart.dart';
import '../widgets/meter_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ResourceType _selectedType = ResourceType.all;

  // Демонстрационные данные для первого этапа.
  // Позже заменим их данными из локальной базы.
  final List<Meter> _meters = [
    Meter(
      id: '1',
      name: 'Холодная вода',
      type: ResourceType.water,
      number: 'ВХ-102458',
      lastReading: 128.45,
      previousReading: 125.20,
      lastSubmission: DateTime(2026, 10, 25),
      tariff: 45.20,
      monthlyConsumption: [2.8, 3.1, 2.6, 3.4, 3.0, 3.25],
    ),
    Meter(
      id: '2',
      name: 'Горячая вода',
      type: ResourceType.water,
      number: 'ВГ-102459',
      lastReading: 76.80,
      previousReading: 74.10,
      lastSubmission: DateTime(2026, 10, 25),
      tariff: 210.50,
      monthlyConsumption: [2.1, 2.4, 2.2, 2.8, 2.5, 2.7],
    ),
    Meter(
      id: '3',
      name: 'Газ',
      type: ResourceType.gas,
      number: 'ГС-208731',
      lastReading: 542.60,
      previousReading: 537.10,
      lastSubmission: DateTime(2026, 10, 24),
      tariff: 8.20,
      monthlyConsumption: [4.8, 5.2, 4.9, 5.6, 5.1, 5.5],
    ),
    Meter(
      id: '4',
      name: 'Электричество',
      type: ResourceType.electricity,
      number: 'ЭЛ-604821',
      lastReading: 2486.30,
      previousReading: 2362.80,
      lastSubmission: DateTime(2026, 10, 26),
      tariff: 6.50,
      monthlyConsumption: [105, 118, 112, 121, 116, 123.5],
    ),
  ];

  List<Meter> get _filteredMeters {
    if (_selectedType == ResourceType.all) {
      return _meters;
    }

    return _meters.where((meter) => meter.type == _selectedType).toList();
  }

  double get _totalEstimatedCost {
    return _filteredMeters.fold(0, (sum, meter) => sum + meter.estimatedCost);
  }

  String _formatMoney(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final buffer = StringBuffer();

    for (var i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(' ');
      }

      buffer.write(integerPart[i]);
    }

    return '${buffer.toString()},${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredMeters = _filteredMeters;
    final selectedChartMeter = filteredMeters.isNotEmpty
        ? filteredMeters.first
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'МОЙ ДОМ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: Color(0xFF176B5B),
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Учёт ресурсов',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        toolbarHeight: 76,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFE2F1EB),
              child: Icon(
                Icons.home_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _buildWelcome(),
            const SizedBox(height: 22),
            _buildSummary(),
            const SizedBox(height: 26),
            _buildSectionHeader(
              title: 'Мои счётчики',
              subtitle: '${filteredMeters.length} прибора учёта',
            ),
            const SizedBox(height: 14),
            _buildFilters(),
            const SizedBox(height: 14),
            ...filteredMeters.map(
              (meter) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MeterCard(
                  meter: meter,
                  onTap: () => _showMeterInfo(meter),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _buildSectionHeader(
              title: 'Потребление',
              subtitle: 'Динамика за 6 месяцев',
            ),
            const SizedBox(height: 14),
            if (selectedChartMeter != null)
              ConsumptionChart(meter: selectedChartMeter),
            const SizedBox(height: 18),
            _buildNotice(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF176B5B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Коммунальные расходы',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 9),
                Text(
                  '${_formatMoney(_totalEstimatedCost)} ₽',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Предварительная оценка за период',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final waterCount = _meters
        .where((meter) => meter.type == ResourceType.water)
        .length;
    final gasCount = _meters
        .where((meter) => meter.type == ResourceType.gas)
        .length;
    final electricityCount = _meters
        .where((meter) => meter.type == ResourceType.electricity)
        .length;

    return Row(
      children: [
        Expanded(
          child: _summaryItem(
            icon: Icons.water_drop_rounded,
            label: 'Вода',
            count: waterCount,
            color: ResourceType.water.color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryItem(
            icon: Icons.local_fire_department_rounded,
            label: 'Газ',
            count: gasCount,
            color: ResourceType.gas.color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryItem(
            icon: Icons.bolt_rounded,
            label: 'Свет',
            count: electricityCount,
            color: ResourceType.electricity.color,
          ),
        ),
      ],
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF18332E),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF18332E),
            ),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ResourceType.values.map((type) {
          final selected = type == _selectedType;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(type.title),
              avatar: Icon(
                type.icon,
                size: 17,
                color: selected ? Colors.white : type.color,
              ),
              selected: selected,
              showCheckmark: false,
              selectedColor: const Color(0xFF176B5B),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF354943),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              side: BorderSide(
                color: selected
                    ? const Color(0xFF176B5B)
                    : const Color(0xFFE6ECE9),
              ),
              onSelected: (_) {
                setState(() {
                  _selectedType = type;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F2ED),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF176B5B)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Суммы рассчитаны по демонстрационным тарифам. '
              'Фактическая стоимость может отличаться от начислений '
              'поставщика коммунальных услуг.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF315D50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMeterInfo(Meter meter) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(meter.type.icon, color: meter.type.color, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      meter.name,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _detailRow('Тип ресурса', meter.type.title),
              _detailRow('Номер счётчика', meter.number),
              _detailRow(
                'Предыдущее показание',
                '${meter.previousReading.toStringAsFixed(2)} '
                    '${meter.type.unit}',
              ),
              _detailRow(
                'Последнее показание',
                '${meter.lastReading.toStringAsFixed(2)} '
                    '${meter.type.unit}',
              ),
              _detailRow(
                'Расход за период',
                '${meter.consumption.toStringAsFixed(2)} '
                    '${meter.type.unit}',
              ),
              _detailRow(
                'Расчётная стоимость',
                '${meter.estimatedCost.toStringAsFixed(2)} ₽',
              ),
              const SizedBox(height: 8),
              const Text(
                'Подробная история показаний и сканирование '
                'камерой будут добавлены на следующих этапах.',
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
