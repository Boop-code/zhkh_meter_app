import 'package:flutter/foundation.dart';

import '../models/meter.dart';
import '../models/meter_reading.dart';
import '../repositories/reading_repository.dart';

class MeterDetailsViewModel extends ChangeNotifier {
  MeterDetailsViewModel({required this.meter, ReadingRepository? repository})
    : _repository = repository ?? ReadingRepository() {
    loadReadings();
  }

  final Meter meter;
  final ReadingRepository _repository;

  List<MeterReading> _readings = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<MeterReading> get readings => List.unmodifiable(_readings);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  double get currentReading => _readings.isNotEmpty ? _readings.first.value : 0;

  double get previousReading {
    if (_readings.length > 1) {
      return _readings[1].value;
    }

    return currentReading;
  }

  double get consumption => currentReading - previousReading;

  double get estimatedCost => consumption * meter.tariff;

  String get unit => meter.type.unit;

  String get formattedConsumption => '${consumption.toStringAsFixed(2)} $unit';

  String get formattedCost => '${estimatedCost.toStringAsFixed(2)} ₽';

  Future<void> loadReadings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _readings = await _repository.getForMeter(meter.id);
    } catch (error) {
      _errorMessage = 'Не удалось загрузить историю: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReading(double value) async {
    if (value < currentReading) {
      throw ArgumentError('Новое показание не может быть меньше предыдущего.');
    }

    final now = DateTime.now();

    await _repository.add(
      id: '${meter.id}-${now.microsecondsSinceEpoch}',
      meterId: meter.id,
      date: now,
      value: value,
    );

    await loadReadings();
  }
}
