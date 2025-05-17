import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/api_config.dart'; // Import the API config
import 'invoice_upload_datasource.dart';

class HttpInvoiceUploadDataSource implements InvoiceUploadDataSource {
  final String baseUrl;
  final http.Client client;

  HttpInvoiceUploadDataSource({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  @override
  Future<String> uploadInvoiceFile({
    required File invoiceFile,
    required String userId,
    bool useOpenCV = false,
    String? categoryId,
    String? sharedGroupId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/upload-invoice');

      developer.log('Uploading invoice to $uri', name: 'invoice_upload');
      developer.log('File path: ${invoiceFile.path}', name: 'invoice_upload');

      // Create multipart request
      var request = http.MultipartRequest('POST', uri);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        invoiceFile.path,
      ));

      // Add parameters
      request.fields['userId'] = userId;
      request.fields['useOpenCV'] = useOpenCV.toString();
      if (categoryId != null) request.fields['categoryId'] = categoryId;
      if (sharedGroupId != null)
        request.fields['sharedGroupId'] = sharedGroupId;

      developer.log('Request parameters: ${request.fields}',
          name: 'invoice_upload');

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      developer.log('Response status: ${response.statusCode}',
          name: 'invoice_upload');
      developer.log('Response body: $responseBody', name: 'invoice_upload');

      // Check if successful
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
            'Failed to upload invoice: ${response.statusCode}, $responseBody');
      }
    } catch (e) {
      developer.log('Error uploading invoice: $e',
          name: 'invoice_upload', error: e);
      throw Exception('Error uploading invoice: $e');
    }
  }
}

final invoiceUploadDataSourceProvider =
    Provider<InvoiceUploadDataSource>((ref) {
  // Use the centralized API configuration
  final baseUrl = ApiConfig().getApiUrl('invoice');
  developer.log('Using API base URL for invoice uploads: $baseUrl',
      name: 'invoice_upload');

  return HttpInvoiceUploadDataSource(baseUrl: baseUrl);
});
