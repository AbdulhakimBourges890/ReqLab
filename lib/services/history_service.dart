import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class HistoryEntry {
  HistoryEntry({
    required this.id,
    required this.date,
    required this.method,
    required this.url,
    required this.params,
    required this.requestHeaders,
    required this.requestBody,
    required this.status,
    required this.reason,
    required this.responseTime,
    required this.responseSize,
    required this.responseHeaders,
    required this.responseBody,
    required this.error,
  });

  final String id;
  final DateTime date;

  final String method;
  final String url;

  final Map<String, String> params;
  final Map<String, String> requestHeaders;
  final String? requestBody;

  final int? status;
  final String? reason;
  final int responseTime;
  final int responseSize;
  final Map<String, String> responseHeaders;
  final String responseBody;
  final String? error;

  bool get failed => error != null;

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    Map<String, String> readMap(dynamic value) {
      if (value is! Map) return {};

      return value.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    return HistoryEntry(
      id: json['id'] ?? '',
      date:
          DateTime.tryParse(json['date'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      method: json['method'] ?? 'GET',
      url: json['url'] ?? '',
      params: readMap(json['params']),
      requestHeaders: readMap(json['requestHeaders']),
      requestBody: json['requestBody'],
      status: json['status'],
      reason: json['reason'],
      responseTime: json['responseTime'] ?? 0,
      responseSize: json['responseSize'] ?? 0,
      responseHeaders: readMap(json['responseHeaders']),
      responseBody: json['responseBody'] ?? '',
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'method': method,
      'url': url,
      'params': params,
      'requestHeaders': requestHeaders,
      'requestBody': requestBody,
      'status': status,
      'reason': reason,
      'responseTime': responseTime,
      'responseSize': responseSize,
      'responseHeaders': responseHeaders,
      'responseBody': responseBody,
      'error': error,
    };
  }
}

class HistoryService {
  static const String _key = 'reqlab_request_history';

  static Future<List<HistoryEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> data = jsonDecode(raw);

      final entries = data
          .map((item) => HistoryEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      entries.sort((a, b) => b.date.compareTo(a.date));

      return entries;
    } catch (_) {
      return [];
    }
  }

  static Future<void> add({
    required String method,
    required String url,
    required Map<String, String> params,
    required Map<String, String> requestHeaders,
    required String? requestBody,
    required ApiResult result,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final entry = HistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      method: method,
      url: url,
      params: Map.from(params),
      requestHeaders: Map.from(requestHeaders),
      requestBody: requestBody,
      status: result.status,
      reason: result.reason,
      responseTime: result.time.inMilliseconds,
      responseSize: result.size,
      responseHeaders: Map.from(result.headers),
      responseBody: result.body,
      error: result.error,
    );

    final entries = await getAll();

    entries.insert(0, entry);

    await prefs.setString(
      _key,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAll();

    entries.removeWhere((e) => e.id == id);

    await prefs.setString(
      _key,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
