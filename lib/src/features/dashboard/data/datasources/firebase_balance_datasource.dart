import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/balance.dart';
import '../../domain/entities/top_category.dart';
import '../../domain/entities/recent_transaction.dart';
import '../../../../features/categories/domain/entities/transactions_by_category_dto.dart';

part 'firebase_balance_datasource.g.dart';

class FirebaseBalanceDataSource {
  final String baseUrl;
  final http.Client client;

  FirebaseBalanceDataSource({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<Balance> getMonthlyBalance(String userId) async {
    final url = '$baseUrl/users/$userId/monthly-balance';
    developer.log('Making API request to: $url', name: 'balance_datasource');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
      );

      developer.log('Response status code: ${response.statusCode}',
          name: 'balance_datasource');

      if (response.statusCode == 200) {
        developer.log('Response body: ${response.body}',
            name: 'balance_datasource');
        final Map<String, dynamic> data = json.decode(response.body);
        return Balance.fromJson(data);
      } else {
        developer.log('Error response: ${response.body}',
            name: 'balance_datasource');
        throw Exception('Failed to load balance: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('Network error: $e',
          name: 'balance_datasource', error: e, stackTrace: stack);
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<List<TopCategory>> getTopCategories(String userId,
      {int? limit}) async {
    final url =
        '$baseUrl/users/$userId/top-categories${limit != null ? '?limit=$limit' : ''}';
    developer.log('Making API request to: $url', name: 'categories_datasource');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
      );

      developer.log('Response status code: ${response.statusCode}',
          name: 'categories_datasource');

      if (response.statusCode == 200) {
        developer.log('Response body: ${response.body}',
            name: 'categories_datasource');
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => TopCategory.fromJson(item)).toList();
      } else {
        developer.log('Error response: ${response.body}',
            name: 'categories_datasource');
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('Network error: $e',
          name: 'categories_datasource', error: e, stackTrace: stack);
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<List<RecentTransaction>> getRecentTransactions(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    // Build URL with query parameters if provided
    String url = '$baseUrl/users/$userId/recent-transactions';

    // Build query parameters
    final queryParams = <String, String>{};
    if (startDate != null) {
      queryParams['startDate'] =
          startDate.toIso8601String().split('T')[0]; // YYYY-MM-DD format
    }
    if (endDate != null) {
      queryParams['endDate'] =
          endDate.toIso8601String().split('T')[0]; // YYYY-MM-DD format
    }
    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }

    // Add query parameters to URL if any exist
    if (queryParams.isNotEmpty) {
      url += '?';
      url += queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    }

    developer.log('Making API request to: $url',
        name: 'transactions_datasource');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8'
        },
      );

      developer.log('Response status code: ${response.statusCode}',
          name: 'transactions_datasource');

      if (response.statusCode == 200) {
        developer.log('Response body: ${response.body}',
            name: 'transactions_datasource');
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => RecentTransaction.fromJson(item)).toList();
      } else {
        developer.log('Error response: ${response.body}',
            name: 'transactions_datasource');
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('Network error: $e',
          name: 'transactions_datasource', error: e, stackTrace: stack);
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<bool> deleteTransaction(int transactionId, String userId) async {
    final url = '$baseUrl/transactions/$transactionId?userId=$userId';
    developer.log('Making API request to delete transaction: $url',
        name: 'transactions_datasource');

    try {
      final response = await client.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
      );

      developer.log('Delete response status code: ${response.statusCode}',
          name: 'transactions_datasource');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        developer.log('Delete response body: $responseBody',
            name: 'transactions_datasource');
        return responseBody['success'] == true;
      } else {
        developer.log('Error response: ${response.body}',
            name: 'transactions_datasource');
        throw Exception('Failed to delete transaction: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('Network error during delete: $e',
          name: 'transactions_datasource', error: e, stackTrace: stack);
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<bool> updateTransaction(int transactionId, String userId,
      double amount, String title, String notes) async {
    final url = '$baseUrl/transactions/$transactionId?userId=$userId';
    developer.log('Making API request to update transaction: $url',
        name: 'transactions_datasource');

    try {
      final Map<String, dynamic> requestBody = {
        'amount': amount,
        'title': title,
      };

      if (notes.isNotEmpty) {
        requestBody['description'] = notes;
      }

      final response = await client.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: json.encode(requestBody),
      );

      developer.log('Update response status code: ${response.statusCode}',
          name: 'transactions_datasource');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        developer.log('Update response body: $responseBody',
            name: 'transactions_datasource');
        return responseBody['success'] == true;
      } else {
        developer.log('Error response: ${response.body}',
            name: 'transactions_datasource');
        throw Exception('Failed to update transaction: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('Network error during update: $e',
          name: 'transactions_datasource', error: e, stackTrace: stack);
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // New method to get transactions by category
  Future<TransactionsByCategoryDTO> getTransactionsByCategory(
    String userId,
    String categoryId, {
    int? month,
    int? year,
  }) async {
    // Build URL with query parameters
    String url =
        '$baseUrl/users/$userId/transactions/by-category?categoryId=$categoryId';

    if (month != null) {
      url += '&month=$month';
    }
    if (year != null) {
      url += '&year=$year';
    }

    developer.log('Making API request to: $url', name: 'category_transactions');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
      );

      developer.log('Response status code: ${response.statusCode}',
          name: 'category_transactions');

      if (response.statusCode == 200) {
        developer.log('Response body: ${response.body}',
            name: 'category_transactions');
        final Map<String, dynamic> data = json.decode(response.body);
        return TransactionsByCategoryDTO.fromJson(data);
      } else {
        developer.log('Error response: ${response.body}',
            name: 'category_transactions');
        throw Exception(
            'Failed to load transactions by category: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('Network error: $e',
          name: 'category_transactions', error: e, stackTrace: stack);

      // Return mock data during development
      developer.log('Returning mock data for category transactions',
          name: 'category_transactions');
      return _getMockCategoryTransactions(categoryId);
    }
  }

  // Mock data method for development testing
  TransactionsByCategoryDTO _getMockCategoryTransactions(String categoryId) {
    final now = DateTime.now();
    final transactions = <Map<String, dynamic>>[];

    // Create mock transactions based on category ID
    if (categoryId == '1') {
      // Food & Drink
      transactions.addAll([
        {
          'id': 101,
          'amount': 85000,
          'date': now.subtract(const Duration(days: 1)).toIso8601String(),
          'description': 'McDonald\'s',
          'type': 'DEBITO',
          'categoryId': 1,
          'categoryName': 'Comida y Bebida',
          'categoryEmoji': '🍔',
          'location': 'Shopping del Sol'
        },
        {
          'id': 102,
          'amount': 120000,
          'date': now.subtract(const Duration(days: 1)).toIso8601String(),
          'description': 'Pizza Hut',
          'type': 'DEBITO',
          'categoryId': 1,
          'categoryName': 'Comida y Bebida',
          'categoryEmoji': '🍔',
          'location': 'Shopping Mariscal'
        },
        {
          'id': 103,
          'amount': 45000,
          'date': now.subtract(const Duration(days: 3)).toIso8601String(),
          'description': 'Café Havanna',
          'type': 'DEBITO',
          'categoryId': 1,
          'categoryName': 'Comida y Bebida',
          'categoryEmoji': '🍔',
          'location': 'Paseo La Galería'
        },
        {
          'id': 104,
          'amount': 237500,
          'date': now.subtract(const Duration(days: 5)).toIso8601String(),
          'description': 'Supermercado Stock',
          'type': 'DEBITO',
          'categoryId': 1,
          'categoryName': 'Comida y Bebida',
          'categoryEmoji': '🍔',
          'location': 'Villa Morra'
        },
        {
          'id': 105,
          'amount': 345000,
          'date': now.subtract(const Duration(days: 10)).toIso8601String(),
          'description': 'La Cabrera',
          'type': 'DEBITO',
          'categoryId': 1,
          'categoryName': 'Comida y Bebida',
          'categoryEmoji': '🍔',
          'location': 'Carmelitas'
        },
      ]);
    } else if (categoryId == '2') {
      // Transport
      transactions.addAll([
        {
          'id': 201,
          'amount': 35000,
          'date': now.subtract(const Duration(days: 2)).toIso8601String(),
          'description': 'Uber',
          'type': 'DEBITO',
          'categoryId': 2,
          'categoryName': 'Transporte',
          'categoryEmoji': '🚗',
          'location': 'Asunción - Lambaré'
        },
        {
          'id': 202,
          'amount': 210000,
          'date': now.subtract(const Duration(days: 4)).toIso8601String(),
          'description': 'Combustible',
          'type': 'DEBITO',
          'categoryId': 2,
          'categoryName': 'Transporte',
          'categoryEmoji': '🚗',
          'location': 'Petrobras - Aviadores'
        },
      ]);
    }

    // Calculate total amount
    double totalAmount = 0;
    for (var tx in transactions) {
      totalAmount += tx['amount'];
    }

    return TransactionsByCategoryDTO.fromJson({
      'transactions': transactions,
      'totalAmount': totalAmount,
    });
  }
}

@riverpod
FirebaseBalanceDataSource balanceDataSource(BalanceDataSourceRef ref) {
  // Choose the correct host based on platform
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

  final baseUrl = '$host/api/v1/bff';
  developer.log('Using API base URL: $baseUrl', name: 'balance_datasource');

  return FirebaseBalanceDataSource(baseUrl: baseUrl);
}
