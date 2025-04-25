import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'bank_statement_upload_datasource.dart';

class HttpBankStatementUploadDataSource
    implements BankStatementUploadDataSource {
  final String baseUrl;
  final http.Client client;

  HttpBankStatementUploadDataSource({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  @override
  Future<String> uploadBankStatementFile({
    required File bankStatementFile,
    required String userId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/upload');

      developer.log('Uploading bank statement to $uri',
          name: 'bank_statement_upload');
      developer.log('File path: ${bankStatementFile.path}',
          name: 'bank_statement_upload');

      // Create multipart request
      var request = http.MultipartRequest('POST', uri);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        bankStatementFile.path,
      ));

      // Add parameters
      request.fields['userId'] = userId;

      developer.log('Request parameters: ${request.fields}',
          name: 'bank_statement_upload');

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      developer.log('Response status: ${response.statusCode}',
          name: 'bank_statement_upload');
      developer.log('Response body: $responseBody',
          name: 'bank_statement_upload');

      // Check if successful
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
            'Failed to upload bank statement: ${response.statusCode}, $responseBody');
      }
    } catch (e) {
      developer.log('Error uploading bank statement: $e',
          name: 'bank_statement_upload', error: e);
      throw Exception('Error uploading bank statement: $e');
    }
  }
}

final bankStatementUploadDataSourceProvider =
    Provider<BankStatementUploadDataSource>((ref) {
  // Choose the correct host based on platform - same as in invoice_upload_datasource
  String host;

  if (kIsWeb) {
    // Web uses the current origin
    host = 'http://localhost:8080';
  } else if (Platform.isAndroid) {
    // Android emulator needs special IP for host's localhost
    host = 'http://10.0.2.2:8080';
  } else {
    // iOS simulator and desktop can use localhost
    host = 'http://localhost:8080';
  }

  final baseUrl = '$host/api/v1/invoice';
  developer.log('Using Bank Statement API base URL: $baseUrl',
      name: 'bank_statement_upload');

  return HttpBankStatementUploadDataSource(baseUrl: baseUrl);
});
