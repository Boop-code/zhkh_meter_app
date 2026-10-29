
class MeterReading {
  const MeterReading({
    required this.id,
    required this.meterId,
    required this.date,
    required this.value,
  });

  final String id;
  final String meterId;
  final DateTime date;
  final double value;

  double differenceFrom(double previousValue) {
    return value - previousValue;
  }
}
