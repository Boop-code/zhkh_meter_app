
import 'package:flutter/material.dart';

import '../models/meter.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    _meters = [
      Meter(
        id: '1',
        name: 'Холодная вода',
        type: ResourceType.water,
        number: 'ХВС-001',
        lastReading: 125.4,
        previousReading: 119.8,
        lastSubmission: DateTime(2026, 10, 25),
        tariff: 45.12,
        monthlyConsumption: [4.2, 3.8, 4.5, 4.1, 4.7, 5.6],
      ),
      Meter(
        id: '2',
        name: 'Горячая вода',
        type: ResourceType.water,
        number: 'ГВС-001',
        lastReading: 78.6,
        previousReading: 75.2,
        lastSubmission: DateTime(2026, 10, 25),
        tariff: 198.19,
        monthlyConsumption: [2.8, 3.1, 2.9, 3.4, 3.2, 3.4],
      ),
      Meter(
        id: '3',
        name: 'Газ',
        type: ResourceType.gas,
        number: 'ГАЗ-001',
        lastReading: 542.8,
        previousReading: 531.5,
        lastSubmission: DateTime(2026, 10, 24),
        tariff: 8.12,
        monthlyConsumption: [9.4, 10.1, 8.7, 11.2, 10.8, 11.3],
      ),
      Meter(
        id: '4',
        name: 'Электричество',
        type: ResourceType.electricity,
        number: 'ЭЛ-001',
        lastReading: 3284.6,
        previousReading: 3160.2,
        lastSubmission: DateTime(2026, 10, 24),
        tariff: 6.99,
        monthlyConsumption: [112.0, 118.5, 105.3, 121.8, 116.4, 124.4],
      ),
    ];
  }

  late final List<Meter> _meters;

  ResourceType _selectedType = ResourceType.all;

  List<Meter> get meters => List.unmodifiable(_meters);

  ResourceType get selectedType => _selectedType;

  List<Meter> get filteredMeters {
    if (_selectedType == ResourceType.all) {
      return meters;
    }

    return _meters
        .where((meter) => meter.type == _selectedType)
        .toList();
  }

  int get metersCount => filteredMeters.length;

  double get totalEstimatedCost {
    return filteredMeters.fold<double>(
      0,
          (total, meter) => total + meter.estimatedCost,
    );
  }

  double get totalConsumption {
    return filteredMeters.fold<double>(
      0,
          (total, meter) => total + meter.consumption,
    );
  }

  void selectResource(ResourceType type) {
    if (_selectedType == type) {
      return;
    }

    _selectedType = type;
    notifyListeners();
  }
}
