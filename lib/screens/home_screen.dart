
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meter.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/consumption_chart.dart';
import '../widgets/meter_card.dart';
import 'meter_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatMoney(double value) {
    return '${value.toStringAsFixed(2).replaceAll('.', ',')} ₽';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final meters = viewModel.filteredMeters;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Учёт ресурсов',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Ваши приборы учёта ЖКХ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFE5EEFF),
              child: Icon(
                Icons.person_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildWelcome(),
            const SizedBox(height: 20),
            _buildSummary(viewModel),
            const SizedBox(height: 24),
            _buildSectionHeader(
              title: 'Мои счётчики',
              subtitle: '${viewModel.metersCount} прибора учёта',
            ),
            const SizedBox(height: 12),
            _buildFilters(context, viewModel),
            const SizedBox(height: 16),
            if (meters.isEmpty)
              _buildEmptyState()
            else
              ...meters.map(
                    (meter) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MeterCard(
                    meter: meter,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MeterDetailsScreen(meter: meter),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 12),
            _buildSectionHeader(
              title: 'История потребления',
              subtitle: 'Динамика по последним месяцам',
            ),
            const SizedBox(height: 12),
            if (meters.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meters.first.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 220,
                        child: ConsumptionChart(
                          meter: meters.first,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildEmptyState(),
            const SizedBox(height: 16),
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
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2878E5),
            Color(0xFF55A0F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.home_work_outlined,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(height: 14),
          Text(
            'Контролируйте расходы',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Все показания и расходы на коммунальные ресурсы в одном месте.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(HomeViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _summaryItem(
            icon: Icons.speed_outlined,
            title: 'Приборы',
            value: '${viewModel.metersCount}',
            subtitle: 'в выбранной категории',
            color: const Color(0xFF2878E5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryItem(
            icon: Icons.payments_outlined,
            title: 'Расходы',
            value: _formatMoney(viewModel.totalEstimatedCost),
            subtitle: 'предварительно',
            color: const Color(0xFF15966B),
          ),
        ),
      ],
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(
      BuildContext context,
      HomeViewModel viewModel,
      ) {
    const resourceTypes = [
      ResourceType.all,
      ResourceType.water,
      ResourceType.gas,
      ResourceType.electricity,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: resourceTypes.map((type) {
          final isSelected = viewModel.selectedType == type;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(type.title),
              selected: isSelected,
              avatar: Icon(
                type.icon,
                size: 18,
                color: isSelected ? Colors.white : type.color,
              ),
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF263247),
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFFE5E9F0),
              ),
              onSelected: (_) => viewModel.selectResource(type),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 42,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'Нет приборов в этой категории',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF2878E5),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Суммы рассчитаны по демонстрационным показаниям и тарифам. '
                  'Они могут отличаться от фактических начислений.',
              style: TextStyle(
                color: Color(0xFF304B70),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
