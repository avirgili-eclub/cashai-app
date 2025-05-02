// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoriesWithLimitHash() =>
    r'abf1750cbfe0bb533dc3ea56e186c7d5b0c07f3c';

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

/// See also [categoriesWithLimit].
@ProviderFor(categoriesWithLimit)
const categoriesWithLimitProvider = CategoriesWithLimitFamily();

/// See also [categoriesWithLimit].
class CategoriesWithLimitFamily extends Family<AsyncValue<List<TopCategory>>> {
  /// See also [categoriesWithLimit].
  const CategoriesWithLimitFamily();

  /// See also [categoriesWithLimit].
  CategoriesWithLimitProvider call({
    required int? limit,
  }) {
    return CategoriesWithLimitProvider(
      limit: limit,
    );
  }

  @override
  CategoriesWithLimitProvider getProviderOverride(
    covariant CategoriesWithLimitProvider provider,
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
  String? get name => r'categoriesWithLimitProvider';
}

/// See also [categoriesWithLimit].
class CategoriesWithLimitProvider
    extends AutoDisposeFutureProvider<List<TopCategory>> {
  /// See also [categoriesWithLimit].
  CategoriesWithLimitProvider({
    required int? limit,
  }) : this._internal(
          (ref) => categoriesWithLimit(
            ref as CategoriesWithLimitRef,
            limit: limit,
          ),
          from: categoriesWithLimitProvider,
          name: r'categoriesWithLimitProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoriesWithLimitHash,
          dependencies: CategoriesWithLimitFamily._dependencies,
          allTransitiveDependencies:
              CategoriesWithLimitFamily._allTransitiveDependencies,
          limit: limit,
        );

  CategoriesWithLimitProvider._internal(
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
    FutureOr<List<TopCategory>> Function(CategoriesWithLimitRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoriesWithLimitProvider._internal(
        (ref) => create(ref as CategoriesWithLimitRef),
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
    return _CategoriesWithLimitProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesWithLimitProvider && other.limit == limit;
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
mixin CategoriesWithLimitRef
    on AutoDisposeFutureProviderRef<List<TopCategory>> {
  /// The parameter `limit` of this provider.
  int? get limit;
}

class _CategoriesWithLimitProviderElement
    extends AutoDisposeFutureProviderElement<List<TopCategory>>
    with CategoriesWithLimitRef {
  _CategoriesWithLimitProviderElement(super.provider);

  @override
  int? get limit => (origin as CategoriesWithLimitProvider).limit;
}

String _$categoriesControllerHash() =>
    r'0d4e813425dbe138e2164a82ca43ec4f7ec83cc8';

/// See also [CategoriesController].
@ProviderFor(CategoriesController)
final categoriesControllerProvider = AutoDisposeAsyncNotifierProvider<
    CategoriesController, List<TopCategory>>.internal(
  CategoriesController.new,
  name: r'categoriesControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoriesControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CategoriesController = AutoDisposeAsyncNotifier<List<TopCategory>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
