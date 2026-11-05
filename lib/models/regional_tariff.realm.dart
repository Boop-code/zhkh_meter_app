// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'regional_tariff.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class RegionalTariff extends _RegionalTariff
    with RealmEntity, RealmObjectBase, RealmObject {
  RegionalTariff(
    String id,
    String region,
    String resourceType,
    double baseCost,
    double norm,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'region', region);
    RealmObjectBase.set(this, 'resourceType', resourceType);
    RealmObjectBase.set(this, 'baseCost', baseCost);
    RealmObjectBase.set(this, 'norm', norm);
  }

  RegionalTariff._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get region => RealmObjectBase.get<String>(this, 'region') as String;
  @override
  set region(String value) => RealmObjectBase.set(this, 'region', value);

  @override
  String get resourceType =>
      RealmObjectBase.get<String>(this, 'resourceType') as String;
  @override
  set resourceType(String value) =>
      RealmObjectBase.set(this, 'resourceType', value);

  @override
  double get baseCost =>
      RealmObjectBase.get<double>(this, 'baseCost') as double;
  @override
  set baseCost(double value) => RealmObjectBase.set(this, 'baseCost', value);

  @override
  double get norm => RealmObjectBase.get<double>(this, 'norm') as double;
  @override
  set norm(double value) => RealmObjectBase.set(this, 'norm', value);

  @override
  Stream<RealmObjectChanges<RegionalTariff>> get changes =>
      RealmObjectBase.getChanges<RegionalTariff>(this);

  @override
  Stream<RealmObjectChanges<RegionalTariff>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<RegionalTariff>(this, keyPaths);

  @override
  RegionalTariff freeze() => RealmObjectBase.freezeObject<RegionalTariff>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'region': region.toEJson(),
      'resourceType': resourceType.toEJson(),
      'baseCost': baseCost.toEJson(),
      'norm': norm.toEJson(),
    };
  }

  static EJsonValue _toEJson(RegionalTariff value) => value.toEJson();
  static RegionalTariff _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'region': EJsonValue region,
        'resourceType': EJsonValue resourceType,
        'baseCost': EJsonValue baseCost,
        'norm': EJsonValue norm,
      } =>
        RegionalTariff(
          fromEJson(id),
          fromEJson(region),
          fromEJson(resourceType),
          fromEJson(baseCost),
          fromEJson(norm),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RegionalTariff._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      RegionalTariff,
      'RegionalTariff',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('region', RealmPropertyType.string),
        SchemaProperty('resourceType', RealmPropertyType.string),
        SchemaProperty('baseCost', RealmPropertyType.double),
        SchemaProperty('norm', RealmPropertyType.double),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
