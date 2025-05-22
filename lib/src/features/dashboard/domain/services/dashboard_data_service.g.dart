// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dependentTopCategoriesHash() =>
    r'89b47f38ea0d0e73d48c30d9270dd90a315b1400';

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

/// A provider that makes top categories depend on transactions
/// This will automatically refresh categories when transactions change
///
/// Copied from [dependentTopCategories].
@ProviderFor(dependentTopCategories)
const dependentTopCategoriesProvider = DependentTopCategoriesFamily();

/// A provider that makes top categories depend on transactions
/// This will automatically refresh categories when transactions change
///
/// Copied from [dependentTopCategories].
class DependentTopCategoriesFamily
    extends Family<AsyncValue<List<TopCategory>>> {
  /// A provider that makes top categories depend on transactions
  /// This will automatically refresh categories when transactions change
  ///
  /// Copied from [dependentTopCategories].
  const DependentTopCategoriesFamily();

  /// A provider that makes top categories depend on transactions
  /// This will automatically refresh categories when transactions change
  ///
  /// Copied from [dependentTopCategories].
  DependentTopCategoriesProvider call({
    int? limit,
  }) {
    return DependentTopCategoriesProvider(
      limit: limit,
    );
  }

  @override
  DependentTopCategoriesProvider getProviderOverride(
    covariant DependentTopCategoriesProvider provider,
  ) {
    return call(
      limit: provider.limit,
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
  String? get name => r'dependentTopCategoriesProvider';
}

/// A provider that makes top categories depend on transactions
/// This will automatically refresh categories when transactions change
///
/// Copied from [dependentTopCategories].
class DependentTopCategoriesProvider
    extends AutoDisposeFutureProvider<List<TopCategory>> {
  /// A provider that makes top categories depend on transactions
  /// This will automatically refresh categories when transactions change
  ///
  /// Copied from [dependentTopCategories].
  DependentTopCategoriesProvider({
    int? limit,
  }) : this._internal(
          (ref) => dependentTopCategories(
            ref as DependentTopCategoriesRef,
            limit: limit,
          ),
          from: dependentTopCategoriesProvider,
          name: r'dependentTopCategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dependentTopCategoriesHash,
          dependencies: DependentTopCategoriesFamily._dependencies,
          allTransitiveDependencies:
              DependentTopCategoriesFamily._allTransitiveDependencies,
          limit: limit,
        );

  DependentTopCategoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int? limit;

  @override
  Override overrideWith(
    FutureOr<List<TopCategory>> Function(DependentTopCategoriesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DependentTopCategoriesProvider._internal(
        (ref) => create(ref as DependentTopCategoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TopCategory>> createElement() {
    return _DependentTopCategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DependentTopCategoriesProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DependentTopCategoriesRef
    on AutoDisposeFutureProviderRef<List<TopCategory>> {
  /// The parameter `limit` of this provider.
  int? get limit;
}

class _DependentTopCategoriesProviderElement
    extends AutoDisposeFutureProviderElement<List<TopCategory>>
    with DependentTopCategoriesRef {
  _DependentTopCategoriesProviderElement(super.provider);

  @override
  int? get limit => (origin as DependentTopCategoriesProvider).limit;
}

String _$dashboardDataHash() => r'0fb5b4de2361d5f1ecd966def9792886af6ed0fa';

/// A provider that combines transaction and category data for a complete dashboard state
///
/// Copied from [dashboardData].
@ProviderFor(dashboardData)
final dashboardDataProvider = AutoDisposeFutureProvider<
    ({
      List<RecentTransaction> transactions,
      List<TopCategory> categories
    })>.internal(
  dashboardData,
  name: r'dashboardDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardDataRef = AutoDisposeFutureProviderRef<
    ({List<RecentTransaction> transactions, List<TopCategory> categories})>;
String _$dashboardDataServiceHash() =>
    r'66e07cf9beae387e0208c6828fcb43029c2cc60d';

/// A service that coordinates refreshing all dashboard data components
///
/// Copied from [DashboardDataService].
@ProviderFor(DashboardDataService)
final dashboardDataServiceProvider =
    AutoDisposeAsyncNotifierProvider<DashboardDataService, void>.internal(
  DashboardDataService.new,
  name: r'dashboardDataServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardDataServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DashboardDataService = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
