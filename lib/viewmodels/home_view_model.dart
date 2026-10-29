import 'package:flutter/foundation.dart';

import '../models/meter.dart';
import '../repositories/meter_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({MeterRepository? repository})
    : _repository = repository ?? MeterRepository() {
    loadMeters();
  }

  final MeterRepository _repository;

  List<Meter> _meters = [];
  ResourceType _selectedType = ResourceType.all;
  bool _isLoading = true;
  String? _errorMessage;

  List<Meter> get meters => List.unmodifiable(_meters);

  ResourceType get selectedType => _selectedType;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<Meter> get filteredMeters {
    if (_selectedType == ResourceType.all) {
      return meters;
    }

    return _meters.where((meter) => meter.type == _selectedType).toList();
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

  Future<void> loadMeters() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _meters = await _repository.getAll();
    } catch (error) {
      _errorMessage = 'Не удалось загрузить счётчики: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMeter({
    required String name,
    required ResourceType type,
    required String number,
    required double tariff,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    await _repository.add(
      id: id,
      name: name.trim(),
      type: type,
      number: number.trim(),
      tariff: tariff,
    );

    await loadMeters();
  }

  Future<void> deleteMeter(String id) async {
    await _repository.delete(id);
    await loadMeters();
  }

  void selectResource(ResourceType type) {
    if (_selectedType == type) {
      return;
    }

    _selectedType = type;
    notifyListeners();
  }
}
