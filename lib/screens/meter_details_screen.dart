import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meter.dart';
import '../models/meter_reading.dart';
import '../viewmodels/meter_details_view_model.dart';
import 'meter_scan_screen.dart';

class MeterDetailsScreen extends StatelessWidget {
  const MeterDetailsScreen({super.key, required this.meter});

  final Meter meter;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MeterDetailsViewModel(meter: meter),
      child: const _MeterDetailsContent(),
    );
  }
}

class _MeterDetailsContent extends StatelessWidget {
  const _MeterDetailsContent();

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  Future<void> _scanReading(
    BuildContext context,
    MeterDetailsViewModel viewModel,
  ) async {
    final result = await Navigator.of(context).push<double>(
      MaterialPageRoute<double>(builder: (_) => const MeterScanScreen()),
    );

    if (!context.mounted || result == null) {
      return;
    }

    if (result < viewModel.currentReading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Новое показание меньше текущего. Проверь цифры перед подтверждением.',
          ),
        ),
      );
      return;
    }

    try {
      await viewModel.addReading(result);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Показание сохранено в SQLite.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить показание: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MeterDetailsViewModel>();
    final meter = viewModel.meter;
    final latestDate = viewModel.readings.isNotEmpty
        ? viewModel.readings.first.date
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Информация о счётчике')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: meter.type.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(meter.type.icon, color: meter.type.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          meter.name,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Номер прибора: ${meter.number}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Текущее показание',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.readings.isEmpty
                        ? 'Нет показаний'
                        : '${_formatNumber(viewModel.currentReading)} ${viewModel.unit}',
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    latestDate == null
                        ? 'Добавь первое показание'
                        : 'Дата: ${_formatDate(latestDate)}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: viewModel.isLoading
                  ? null
                  : () => _scanReading(context, viewModel),
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Text('Сканировать показание камерой'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Расчёт за период',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(
                      'Предыдущее показание',
                      '${_formatNumber(viewModel.previousReading)} ${viewModel.unit}',
                    ),
                    _infoRow(
                      'Текущее показание',
                      viewModel.readings.isEmpty
                          ? '—'
                          : '${_formatNumber(viewModel.currentReading)} ${viewModel.unit}',
                    ),
                    _infoRow(
                      'Расход за период',
                      viewModel.formattedConsumption,
                    ),
                    _infoRow(
                      'Тариф',
                      '${_formatNumber(meter.tariff)} ₽/${viewModel.unit}',
                    ),
                    const Divider(height: 24),
                    _infoRow(
                      'Предварительная стоимость',
                      viewModel.formattedCost,
                      emphasize: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'История показаний',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Записи отсортированы от новых к старым.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            if (viewModel.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (viewModel.errorMessage != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(viewModel.errorMessage!),
                      TextButton(
                        onPressed: viewModel.loadReadings,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              )
            else if (viewModel.readings.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Показаний пока нет. Отсканируй первое показание.',
                  ),
                ),
              )
            else
              ...viewModel.readings.map(
                (reading) => _readingCard(reading, meter),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'История хранится в локальной базе SQLite. Стоимость рассчитывается по тарифу, указанному для счётчика.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF304B70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _readingCard(MeterReading reading, Meter meter) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: meter.type.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.history, color: meter.type.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(reading.date),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Показание счётчика',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_formatNumber(reading.value)} ${meter.type.unit}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: emphasize ? Colors.black87 : Colors.black54,
                fontWeight: emphasize ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
                fontSize: emphasize ? 16 : 14,
                color: emphasize ? const Color(0xFF15966B) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
