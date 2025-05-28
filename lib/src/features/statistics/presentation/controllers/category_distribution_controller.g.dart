// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_distribution_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryDistributionControllerHash() =>
    r'f6fc1b086ecbe943bda0bde054ed2178b1a9c6b0';

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

abstract class _$CategoryDistributionController
    extends BuildlessAutoDisposeAsyncNotifier<List<CategoryStat>> {
  late final String? timeRange;

  FutureOr<List<CategoryStat>> build({
    String? timeRange,
  });
}

/// See also [CategoryDistributionController].
@ProviderFor(CategoryDistributionController)
const categoryDistributionControllerProvider =
    CategoryDistributionControllerFamily();

/// See also [CategoryDistributionController].
class CategoryDistributionControllerFamily
    extends Family<AsyncValue<List<CategoryStat>>> {
  /// See also [CategoryDistributionController].
  const CategoryDistributionControllerFamily();

  /// See also [CategoryDistributionController].
  CategoryDistributionControllerProvider call({
    String? timeRange,
  }) {
    return CategoryDistributionControllerProvider(
      timeRange: timeRange,
    );
  }

  @override
  CategoryDistributionControllerProvider getProviderOverride(
    covariant CategoryDistributionControllerProvider provider,
  ) {
    return call(
      timeRange: provider.timeRange,
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
  String? get name => r'categoryDistributionControllerProvider';
}

/// See also [CategoryDistributionController].
class CategoryDistributionControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<CategoryDistributionController,
        List<CategoryStat>> {
  /// See also [CategoryDistributionController].
  CategoryDistributionControllerProvider({
    String? timeRange,
  }) : this._internal(
          () => CategoryDistributionController()..timeRange = timeRange,
          from: categoryDistributionControllerProvider,
          name: r'categoryDistributionControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryDistributionControllerHash,
          dependencies: CategoryDistributionControllerFamily._dependencies,
          allTransitiveDependencies:
              CategoryDistributionControllerFamily._allTransitiveDependencies,
          timeRange: timeRange,
        );

  CategoryDistributionControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.timeRange,
  }) : super.internal();

  final String? timeRange;

  @override
  FutureOr<List<CategoryStat>> runNotifierBuild(
    covariant CategoryDistributionController notifier,
  ) {
    return notifier.build(
      timeRange: timeRange,
    );
  }

  @override
  Override overrideWith(CategoryDistributionController Function() create) {
    return ProviderOverride(
      origin: this,
      override: CategoryDistributionControllerProvider._internal(
        () => create()..timeRange = timeRange,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        timeRange: timeRange,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CategoryDistributionController,
      List<CategoryStat>> createElement() {
    return _CategoryDistributionControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryDistributionControllerProvider &&
        other.timeRange == timeRange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, timeRange.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoryDistributionControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<CategoryStat>> {
  /// The parameter `timeRange` of this provider.
  String? get timeRange;
}

class _CategoryDistributionControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<
        CategoryDistributionController,
        List<CategoryStat>> with CategoryDistributionControllerRef {
  _CategoryDistributionControllerProviderElement(super.provider);

  @override
  String? get timeRange =>
      (origin as CategoryDistributionControllerProvider).timeRange;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
