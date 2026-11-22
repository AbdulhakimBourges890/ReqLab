import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiResult {
  ApiResult({
    this.status,
    this.reason,
    required this.time,
    this.size = 0,
    this.headers = const {},
    this.body = '',
    this.error,
  });

  final int? status;
  final String? reason;
  final Duration time;
  final int size;
  final Map<String, String> headers;
  final String body;
  final String? error;

  bool get failed => error != null;
}

class ApiService {
  static Future<ApiResult> send({
    required String method,
    required String url,
    Map<String, String> params = const {},
    Map<String, String> headers = const {},
    String? body,
  }) async {
    final sw = Stopwatch()..start();
    try {
      var raw = url.trim();
      if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
        raw = 'https://$raw';
      }
      var uri = Uri.parse(raw);
      if (params.isNotEmpty) {
        uri = uri.replace(queryParameters: {...uri.queryParameters, ...params});
      }

      final req = http.Request(method, uri);
      req.headers.addAll(headers);
      if (body != null && body.trim().isNotEmpty) {
        req.body = body;
        req.headers.putIfAbsent('Content-Type', () => 'application/json');
      }

      final streamed = await req.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(streamed);
      sw.stop();

      return ApiResult(
        status: res.statusCode,
        reason: res.reasonPhrase,
        time: sw.elapsed,
        size: res.bodyBytes.length,
        headers: res.headers,
        body: _pretty(res.body),
      );
    } catch (e) {
      sw.stop();
      return ApiResult(time: sw.elapsed, error: e.toString());
    }
  }

  static String _pretty(String raw) {
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(raw));
    } catch (_) {
      return raw;
    }
  }
}
