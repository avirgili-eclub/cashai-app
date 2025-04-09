import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner;

  LoggingHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    developer.log('HTTP ${request.method} ${request.url}', name: 'network');

    try {
      final response = await _inner.send(request);
      developer.log('HTTP ${response.statusCode} ${request.url}',
          name: 'network');
      return response;
    } catch (e) {
      developer.log('HTTP ERROR ${request.url}: $e', name: 'network', error: e);
      rethrow;
    }
  }
}

// Create a factory for getting a logging-enabled client
http.Client getLoggingClient() {
  return LoggingHttpClient(http.Client());
}
