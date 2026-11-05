import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';
import 'package:zhkh_meter_app/models/regional_tariff.dart';
import 'package:zhkh_meter_app/repositories/tariff_repository.dart';

void main() {
  late Realm realm;
  late TariffRepository repository;

  setUp(() {
    final uniquePath =
        'tariff_test_${DateTime.now().microsecondsSinceEpoch}.realm';

    final configuration = Configuration.local(
      [RegionalTariff.schema],
      path: uniquePath,
      shouldDeleteIfMigrationNeeded: true,
    );

    realm = Realm(configuration);
    repository = TariffRepository(realm: realm);
  });

  tearDown(() {
    repository.close();
  });

  test('сохраняет и получает тариф', () {
    repository.save(
      id: 'test-water-1',
      region: 'Тестовый регион',
      resourceType: 'water',
      baseCost: 45.5,
      norm: 4.2,
    );

    final tariff = repository.getForResource(
      region: 'Тестовый регион',
      resourceType: 'water',
    );

    expect(tariff, isNotNull);
    expect(tariff!.baseCost, 45.5);
    expect(tariff.norm, 4.2);
  });

  test('обновляет существующий тариф', () {
    repository.save(
      id: 'test-water-2',
      region: 'Тестовый регион',
      resourceType: 'water',
      baseCost: 40,
      norm: 4,
    );

    repository.save(
      id: 'test-water-2',
      region: 'Тестовый регион',
      resourceType: 'water',
      baseCost: 50,
      norm: 5,
    );

    final tariff = repository.getForResource(
      region: 'Тестовый регион',
      resourceType: 'water',
    );

    expect(tariff, isNotNull);
    expect(tariff!.baseCost, 50);
    expect(tariff.norm, 5);
  });

  test('удаляет тариф', () {
    repository.save(
      id: 'test-water-3',
      region: 'Тестовый регион',
      resourceType: 'water',
      baseCost: 45,
      norm: 4,
    );

    repository.delete('test-water-3');

    expect(
      repository.getForResource(
        region: 'Тестовый регион',
        resourceType: 'water',
      ),
      isNull,
    );
  });
}
