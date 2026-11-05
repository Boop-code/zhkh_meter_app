import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';
import 'package:zhkh_meter_app/models/regional_tariff.dart';
import 'package:zhkh_meter_app/repositories/tariff_repository.dart';

void main() {
  late Realm realm;
  late TariffRepository repository;

  setUp(() {
    final path = 'tariff_seed_${DateTime.now().microsecondsSinceEpoch}.realm';

    realm = Realm(Configuration.local([RegionalTariff.schema], path: path));

    repository = TariffRepository(realm: realm);
  });

  tearDown(() {
    repository.close();
  });

  test('создаёт три начальных тарифа Гомельской области', () {
    repository.seedDefaultTariffs();

    final tariffs = repository.getForRegion(TariffRepository.defaultRegion);

    expect(tariffs.length, 3);
    expect(
      repository
          .getForResource(
            region: TariffRepository.defaultRegion,
            resourceType: 'water',
          )!
          .baseCost,
      2.2927,
    );
    expect(
      repository
          .getForResource(
            region: TariffRepository.defaultRegion,
            resourceType: 'gas',
          )!
          .baseCost,
      0.586,
    );
    expect(
      repository
          .getForResource(
            region: TariffRepository.defaultRegion,
            resourceType: 'electricity',
          )!
          .baseCost,
      0.3037,
    );
  });

  test('повторное заполнение не создаёт дубликаты', () {
    repository.seedDefaultTariffs();
    repository.seedDefaultTariffs();

    expect(repository.getForRegion(TariffRepository.defaultRegion).length, 3);
  });
}
