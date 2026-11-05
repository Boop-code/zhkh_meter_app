import 'package:realm/realm.dart';

part 'regional_tariff.realm.dart';

@RealmModel()
class _RegionalTariff {
  @PrimaryKey()
  late String id;

  late String region;

  /// Тип ресурса: water, gas или electricity.
  late String resourceType;

  /// Стоимость одной единицы ресурса.
  late double baseCost;

  /// Норматив потребления на одного человека.
  late double norm;
}
