// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionDetailHash() => r'cc4f5ca478b0b864b006e67f519cd4d0bba0cc3d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [transactionDetail].
@ProviderFor(transactionDetail)
const transactionDetailProvider = TransactionDetailFamily();

/// See also [transactionDetail].
class TransactionDetailFamily extends Family<AsyncValue<RecentTransaction>> {
  /// See also [transactionDetail].
  const TransactionDetailFamily();

  /// See also [transactionDetail].
  TransactionDetailProvider call(
    String transactionId,
  ) {
    return TransactionDetailProvider(
      transactionId,
    );
  }

  @override
  TransactionDetailProvider getProviderOverride(
    covariant TransactionDetailProvider provider,
  ) {
    return call(
      provider.transactionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'transactionDetailProvider';
}

/// See also [transactionDetail].
class TransactionDetailProvider
    extends AutoDisposeFutureProvider<RecentTransaction> {
  /// See also [transactionDetail].
  TransactionDetailProvider(
    String transactionId,
  ) : this._internal(
          (ref) => transactionDetail(
            ref as TransactionDetailRef,
            transactionId,
          ),
          from: transactionDetailProvider,
          name: r'transactionDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$transactionDetailHash,
          dependencies: TransactionDetailFamily._dependencies,
          allTransitiveDependencies:
              TransactionDetailFamily._allTransitiveDependencies,
          transactionId: transactionId,
        );

  TransactionDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.transactionId,
  }) : super.internal();

  final String transactionId;

  @override
  Override overrideWith(
    FutureOr<RecentTransaction> Function(TransactionDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionDetailProvider._internal(
        (ref) => create(ref as TransactionDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        transactionId: transactionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<RecentTransaction> createElement() {
    return _TransactionDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionDetailProvider &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, transactionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TransactionDetailRef on AutoDisposeFutureProviderRef<RecentTransaction> {
  /// The parameter `transactionId` of this provider.
  String get transactionId;
}

class _TransactionDetailProviderElement
    extends AutoDisposeFutureProviderElement<RecentTransaction>
    with TransactionDetailRef {
  _TransactionDetailProviderElement(super.provider);

  @override
  String get transactionId =>
      (origin as TransactionDetailProvider).transactionId;
}

String _$transactionsControllerHash() =>
    r'8fe00cabafb83006e8852ccc45d5a9581dc2b516';

/// See also [TransactionsController].
@ProviderFor(TransactionsController)
final transactionsControllerProvider = AutoDisposeAsyncNotifierProvider<
    TransactionsController, List<RecentTransaction>>.internal(
  TransactionsController.new,
  name: r'transactionsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionsController
    = AutoDisposeAsyncNotifier<List<RecentTransaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
