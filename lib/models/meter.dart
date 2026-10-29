import 'package:flutter/material.dart';

enum ResourceType { all, water, gas, electricity }

extension ResourceTypeInfo on ResourceType {
  String get title {
    switch (this) {
      case ResourceType.all:
        return 'Все';
      case ResourceType.water:
        return 'Вода';
      case ResourceType.gas:
        return 'Газ';
      case ResourceType.electricity:
        return 'Электричество';
    }
  }

  String get unit {
    switch (this) {
      case ResourceType.all:
        return '';
      case ResourceType.water:
      case ResourceType.gas:
        return 'м³';
      case ResourceType.electricity:
        return 'кВт·ч';
    }
  }

  IconData get icon {
    switch (this) {
      case ResourceType.all:
        return Icons.dashboard_rounded;
      case ResourceType.water:
        return Icons.water_drop_rounded;
      case ResourceType.gas:
        return Icons.local_fire_department_rounded;
      case ResourceType.electricity:
        return Icons.bolt_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ResourceType.all:
        return const Color(0xFF176B5B);
      case ResourceType.water:
        return const Color(0xFF2878D0);
      case ResourceType.gas:
        return const Color(0xFFDF8B2D);
      case ResourceType.electricity:
        return const Color(0xFF7956C8);
    }
  }
}

class Meter {
  const Meter({
    required this.id,
    required this.name,
    required this.type,
    required this.number,
    required this.lastReading,
    required this.previousReading,
    required this.lastSubmission,
    required this.tariff,
    required this.monthlyConsumption,
  });

  final String id;
  final String name;
  final ResourceType type;
  final String number;
  final double lastReading;
  final double previousReading;
  final DateTime lastSubmission;
  final double tariff;
  final List<double> monthlyConsumption;

  double get consumption => lastReading - previousReading;

  double get estimatedCost => consumption * tariff;
}
