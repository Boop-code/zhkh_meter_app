import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'http://172.20.10.2:3000';

  final http.Client _client;

  Future<List<Map<String, Object?>>> getInitialMeters() async {
    final uri = Uri.parse('$baseUrl/api/meters');

    final response = await _client.get(uri).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Ошибка REST API. Код ответа: ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Некорректный формат ответа сервера');
    }

    if (decoded['success'] != true) {
      throw Exception(
        decoded['message'] ?? 'Сервер не подтвердил получение данных',
      );
    }

    final metersData = decoded['meters'];

    if (metersData is! List) {
      throw const FormatException(
        'В ответе сервера отсутствует список счётчиков',
      );
    }

    return metersData.map((item) {
      if (item is! Map) {
        throw const FormatException('Некорректная запись счётчика');
      }

      final meter = Map<String, dynamic>.from(item);

      final id = meter['id'];
      final name = meter['name'];
      final type = meter['type'];
      final number = meter['number'];

      if (id is! String ||
          id.isEmpty ||
          name is! String ||
          name.isEmpty ||
          type is! String ||
          number is! String) {
        throw const FormatException('У счётчика отсутствуют обязательные поля');
      }

      if (!['water', 'gas', 'electricity'].contains(type)) {
        throw FormatException('Неизвестный тип счётчика: $type');
      }

      final tariff = meter['tariff'] ?? 0;

      if (tariff is! num) {
        throw const FormatException('Некорректное значение тарифа');
      }

      return <String, Object?>{
        'id': id,
        'name': name,
        'type': type,
        'number': number,
        'tariff': tariff.toDouble(),
      };
    }).toList();
  }

  void dispose() {
    _client.close();
  }
}
