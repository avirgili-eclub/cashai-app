import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/balance.dart';
import '../../domain/entities/top_category.dart';
import '../../domain/entities/recent_transaction.dart';

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

  Future<List<TopCategory>> getTopCategories(String userId) async {
    final url = '$baseUrl/users/$userId/top-categories';
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

  Future<List<RecentTransaction>> getRecentTransactions(String userId) async {
    final url = '$baseUrl/users/$userId/recent-transactions';
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
