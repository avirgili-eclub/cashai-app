// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_transactions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryTransactionsControllerHash() =>
    r'a0a5f1bcce1a9a68201ce8a084f55005dad04147';

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

abstract class _$CategoryTransactionsController
    extends BuildlessAutoDisposeAsyncNotifier<TransactionsByCategoryDTO> {
  late final String categoryId;

  FutureOr<TransactionsByCategoryDTO> build(
    String categoryId,
  );
}

/// See also [CategoryTransactionsController].
@ProviderFor(CategoryTransactionsController)
const categoryTransactionsControllerProvider =
    CategoryTransactionsControllerFamily();

/// See also [CategoryTransactionsController].
class CategoryTransactionsControllerFamily
    extends Family<AsyncValue<TransactionsByCategoryDTO>> {
  /// See also [CategoryTransactionsController].
  const CategoryTransactionsControllerFamily();

  /// See also [CategoryTransactionsController].
  CategoryTransactionsControllerProvider call(
    String categoryId,
  ) {
    return CategoryTransactionsControllerProvider(
      categoryId,
    );
  }

  @override
  CategoryTransactionsControllerProvider getProviderOverride(
    covariant CategoryTransactionsControllerProvider provider,
  ) {
    return call(
      provider.categoryId,
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
  String? get name => r'categoryTransactionsControllerProvider';
}

/// See also [CategoryTransactionsController].
class CategoryTransactionsControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<CategoryTransactionsController,
        TransactionsByCategoryDTO> {
  /// See also [CategoryTransactionsController].
  CategoryTransactionsControllerProvider(
    String categoryId,
  ) : this._internal(
          () => CategoryTransactionsController()..categoryId = categoryId,
          from: categoryTransactionsControllerProvider,
          name: r'categoryTransactionsControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryTransactionsControllerHash,
          dependencies: CategoryTransactionsControllerFamily._dependencies,
          allTransitiveDependencies:
              CategoryTransactionsControllerFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  CategoryTransactionsControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  FutureOr<TransactionsByCategoryDTO> runNotifierBuild(
    covariant CategoryTransactionsController notifier,
  ) {
    return notifier.build(
      categoryId,
    );
  }

  @override
  Override overrideWith(CategoryTransactionsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: CategoryTransactionsControllerProvider._internal(
        () => create()..categoryId = categoryId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CategoryTransactionsController,
      TransactionsByCategoryDTO> createElement() {
    return _CategoryTransactionsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryTransactionsControllerProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoryTransactionsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<TransactionsByCategoryDTO> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _CategoryTransactionsControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<
        CategoryTransactionsController,
        TransactionsByCategoryDTO> with CategoryTransactionsControllerRef {
  _CategoryTransactionsControllerProviderElement(super.provider);

  @override
  String get categoryId =>
      (origin as CategoryTransactionsControllerProvider).categoryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
