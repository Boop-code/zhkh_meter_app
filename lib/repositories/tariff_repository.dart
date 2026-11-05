import 'package:realm/realm.dart';

import '../models/regional_tariff.dart';

class TariffRepository {
  TariffRepository({Realm? realm}) : _realm = realm ?? _openRealm();

  final Realm _realm;

  static const String defaultRegion = 'Гомельская область, Беларусь';

  static Realm _openRealm() {
    final configuration = Configuration.local([RegionalTariff.schema]);

    return Realm(configuration);
  }

  List<RegionalTariff> getAll() {
    return _realm.all<RegionalTariff>().toList();
  }

  List<RegionalTariff> getForRegion(String region) {
    return _realm.query<RegionalTariff>(r'region == $0', [region]).toList();
  }

  RegionalTariff? getForResource({
    required String region,
    required String resourceType,
  }) {
    final results = _realm.query<RegionalTariff>(
      r'region == $0 AND resourceType == $1',
      [region, resourceType],
    );

    return results.isEmpty ? null : results.first;
  }

  /// Создаёт начальные учебные тарифы, если их ещё нет.
  /// Существующие пользовательские тарифы не перезаписываются.
  void seedDefaultTariffs() {
    const defaults = [
      _DefaultTariff(
        id: 'gomel-water',
        resourceType: 'water',
        baseCost: 2.2927,
        norm: 4.2,
      ),
      _DefaultTariff(
        id: 'gomel-gas',
        resourceType: 'gas',
        baseCost: 0.586,
        norm: 13.0,
      ),
      _DefaultTariff(
        id: 'gomel-electricity',
        resourceType: 'electricity',
        baseCost: 0.3037,
        norm: 60.0,
      ),
    ];

    _realm.write(() {
      for (final item in defaults) {
        final existing = _realm.query<RegionalTariff>(r'id == $0', [item.id]);

        if (existing.isEmpty) {
          _realm.add(
            RegionalTariff(
              item.id,
              defaultRegion,
              item.resourceType,
              item.baseCost,
              item.norm,
            ),
          );
        }
      }
    });
  }

  void save({
    required String id,
    required String region,
    required String resourceType,
    required double baseCost,
    required double norm,
  }) {
    final tariff = RegionalTariff(id, region, resourceType, baseCost, norm);

    _realm.write(() {
      _realm.add(tariff, update: true);
    });
  }

  void delete(String id) {
    final results = _realm.query<RegionalTariff>(r'id == $0', [id]);

    if (results.isEmpty) return;

    _realm.write(() {
      _realm.delete(results.first);
    });
  }

  void close() {
    _realm.close();
  }
}

class _DefaultTariff {
  const _DefaultTariff({
    required this.id,
    required this.resourceType,
    required this.baseCost,
    required this.norm,
  });

  final String id;
  final String resourceType;
  final double baseCost;
  final double norm;
}
