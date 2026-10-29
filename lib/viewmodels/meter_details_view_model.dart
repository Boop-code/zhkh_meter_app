
import 'package:flutter/foundation.dart';

import '../models/meter.dart';
import '../models/meter_reading.dart';

class MeterDetailsViewModel extends ChangeNotifier {
  MeterDetailsViewModel({
    required this.meter,
  })  : _currentReading = meter.lastReading,
        _previousReading = meter.previousReading {
    _readings = _createDemoReadings();
  }

  final Meter meter;

  late final List<MeterReading> _readings;

  double _currentReading;
  double _previousReading;

  List<MeterReading> get readings {
    final result = List<MeterReading>.of(_readings);
    result.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(result);
  }

  double get currentReading => _currentReading;

  double get previousReading => _previousReading;

  double get consumption => currentReading - previousReading;

  double get estimatedCost => consumption * meter.tariff;

  String get unit => meter.type.unit;

  String get formattedConsumption =>
      '${consumption.toStringAsFixed(2)} $unit';

  String get formattedCost =>
      '${estimatedCost.toStringAsFixed(2)} ₽';

  void addReading(double value) {
    if (value < _currentReading) {
      throw ArgumentError(
        'Новое показание не может быть меньше предыдущего.',
      );
    }

    _previousReading = _currentReading;
    _currentReading = value;

    _readings.add(
      MeterReading(
        id: '${meter.id}-${DateTime.now().microsecondsSinceEpoch}',
        meterId: meter.id,
        date: DateTime.now(),
        value: value,
      ),
    );

    notifyListeners();
  }

  List<MeterReading> _createDemoReadings() {
    final now = meter.lastSubmission;

    return [
      MeterReading(
        id: '${meter.id}-1',
        meterId: meter.id,
        date: now,
        value: meter.lastReading,
      ),
      MeterReading(
        id: '${meter.id}-2',
        meterId: meter.id,
        date: DateTime(now.year, now.month - 1, 25),
        value: meter.previousReading,
      ),
    ];
  }
}