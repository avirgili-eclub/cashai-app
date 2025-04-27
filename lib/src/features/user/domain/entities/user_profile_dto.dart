import 'package:flutter/material.dart';

class UserProfileDTO {
  final String? id;
  final String? username;
  final String? email;
  final String? nickName;
  final String? celular;
  final DateTime? birthDate;
  final double? monthlyIncome;

  // Authentication info
  final String? authProvider;

  // User preferences/settings
  final CurrencyDTO? principalCurrency;
  final List<String>? enabledCurrencies;
  final bool askForAudioCategory;
  final bool askForPhotoCategory;
  final bool askForTransactionCategoryNotification;
  final bool authBiometric;

  // Subscription info
  final SubscriptionDTO? subscription;

  const UserProfileDTO({
    this.id,
    this.username,
    this.email,
    this.nickName,
    this.celular,
    this.birthDate,
    this.monthlyIncome,
    this.authProvider,
    this.principalCurrency,
    this.enabledCurrencies,
    this.askForAudioCategory = true,
    this.askForPhotoCategory = true,
    this.askForTransactionCategoryNotification = false,
    this.authBiometric = false,
    this.subscription,
  });

  factory UserProfileDTO.fromJson(Map<String, dynamic> json) {
    return UserProfileDTO(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      nickName: json['nickName'],
      celular: json['celular'],
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      monthlyIncome: json['monthlyIncome'] != null
          ? double.parse(json['monthlyIncome'].toString())
          : null,
      authProvider: json['authProvider'],
      principalCurrency: json['principalCurrency'] != null
          ? CurrencyDTO.fromJson(json['principalCurrency'])
          : null,
      enabledCurrencies: json['enabledCurrencies'] != null
          ? List<String>.from(json['enabledCurrencies'])
          : null,
      askForAudioCategory: json['askForAudioCategory'] ?? true,
      askForPhotoCategory: json['askForPhotoCategory'] ?? true,
      askForTransactionCategoryNotification:
          json['askForTransactionCategoryNotification'] ?? false,
      authBiometric: json['authBiometric'] ?? false,
      subscription: json['subscription'] != null
          ? SubscriptionDTO.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nickName': nickName,
      'celular': celular,
      'birthDate': birthDate?.toIso8601String(),
      'monthlyIncome': monthlyIncome,
      'authProvider': authProvider,
      'principalCurrency': principalCurrency?.toJson(),
      'enabledCurrencies': enabledCurrencies,
      'askForAudioCategory': askForAudioCategory,
      'askForPhotoCategory': askForPhotoCategory,
      'askForTransactionCategoryNotification':
          askForTransactionCategoryNotification,
      'authBiometric': authBiometric,
      'subscription': subscription?.toJson(),
    };
  }

  // Create a copy with modified fields
  UserProfileDTO copyWith({
    String? id,
    String? username,
    String? email,
    String? nickName,
    String? celular,
    DateTime? birthDate,
    double? monthlyIncome,
    String? authProvider,
    CurrencyDTO? principalCurrency,
    List<String>? enabledCurrencies,
    bool? askForAudioCategory,
    bool? askForPhotoCategory,
    bool? askForTransactionCategoryNotification,
    bool? authBiometric,
    SubscriptionDTO? subscription,
  }) {
    return UserProfileDTO(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      nickName: nickName ?? this.nickName,
      celular: celular ?? this.celular,
      birthDate: birthDate ?? this.birthDate,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      authProvider: authProvider ?? this.authProvider,
      principalCurrency: principalCurrency ?? this.principalCurrency,
      enabledCurrencies: enabledCurrencies ?? this.enabledCurrencies,
      askForAudioCategory: askForAudioCategory ?? this.askForAudioCategory,
      askForPhotoCategory: askForPhotoCategory ?? this.askForPhotoCategory,
      askForTransactionCategoryNotification:
          askForTransactionCategoryNotification ??
              this.askForTransactionCategoryNotification,
      authBiometric: authBiometric ?? this.authBiometric,
      subscription: subscription ?? this.subscription,
    );
  }
}

class CurrencyDTO {
  final String? code;
  final String? symbol;
  final String? name;

  const CurrencyDTO({
    this.code,
    this.symbol,
    this.name,
  });

  factory CurrencyDTO.fromJson(Map<String, dynamic> json) {
    return CurrencyDTO(
      code: json['code'],
      symbol: json['symbol'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'symbol': symbol,
      'name': name,
    };
  }
}

class SubscriptionDTO {
  final String? type;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isTrial;
  final DateTime? trialEndDate;
  final String? description;

  const SubscriptionDTO({
    this.type,
    this.status,
    this.startDate,
    this.endDate,
    this.isTrial = false,
    this.trialEndDate,
    this.description,
  });

  factory SubscriptionDTO.fromJson(Map<String, dynamic> json) {
    return SubscriptionDTO(
      type: json['type'],
      status: json['status'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isTrial: json['isTrial'] ?? false,
      trialEndDate: json['trialEndDate'] != null
          ? DateTime.parse(json['trialEndDate'])
          : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isTrial': isTrial,
      'trialEndDate': trialEndDate?.toIso8601String(),
      'description': description,
    };
  }
}
