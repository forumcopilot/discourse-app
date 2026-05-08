// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'search.dart';

class DiscourseSearchMapper extends ClassMapperBase<DiscourseSearch> {
  DiscourseSearchMapper._();

  static DiscourseSearchMapper? _instance;
  static DiscourseSearchMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscourseSearchMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DiscourseSearch';

  static int _$searchId(DiscourseSearch v) => v.searchId;
  static const Field<DiscourseSearch, int> _f$searchId =
      Field('searchId', _$searchId);
  static int? _$resultCount(DiscourseSearch v) => v.resultCount;
  static const Field<DiscourseSearch, int> _f$resultCount =
      Field('resultCount', _$resultCount, opt: true);
  static String? _$searchType(DiscourseSearch v) => v.searchType;
  static const Field<DiscourseSearch, String> _f$searchType =
      Field('searchType', _$searchType, opt: true);
  static String? _$searchQuery(DiscourseSearch v) => v.searchQuery;
  static const Field<DiscourseSearch, String> _f$searchQuery =
      Field('searchQuery', _$searchQuery, opt: true);
  static List<dynamic>? _$searchConstraints(DiscourseSearch v) =>
      v.searchConstraints;
  static const Field<DiscourseSearch, List<dynamic>> _f$searchConstraints =
      Field('searchConstraints', _$searchConstraints, opt: true);
  static String? _$searchOrder(DiscourseSearch v) => v.searchOrder;
  static const Field<DiscourseSearch, String> _f$searchOrder =
      Field('searchOrder', _$searchOrder, opt: true);
  static bool? _$searchGrouping(DiscourseSearch v) => v.searchGrouping;
  static const Field<DiscourseSearch, bool> _f$searchGrouping =
      Field('searchGrouping', _$searchGrouping, opt: true);
  static List<dynamic>? _$warnings(DiscourseSearch v) => v.warnings;
  static const Field<DiscourseSearch, List<dynamic>> _f$warnings =
      Field('warnings', _$warnings, opt: true);
  static int? _$userId(DiscourseSearch v) => v.userId;
  static const Field<DiscourseSearch, int> _f$userId =
      Field('userId', _$userId, opt: true);
  static int? _$searchDate(DiscourseSearch v) => v.searchDate;
  static const Field<DiscourseSearch, int> _f$searchDate =
      Field('searchDate', _$searchDate, opt: true);
  static String? _$queryHash(DiscourseSearch v) => v.queryHash;
  static const Field<DiscourseSearch, String> _f$queryHash =
      Field('queryHash', _$queryHash, opt: true);

  @override
  final MappableFields<DiscourseSearch> fields = const {
    #searchId: _f$searchId,
    #resultCount: _f$resultCount,
    #searchType: _f$searchType,
    #searchQuery: _f$searchQuery,
    #searchConstraints: _f$searchConstraints,
    #searchOrder: _f$searchOrder,
    #searchGrouping: _f$searchGrouping,
    #warnings: _f$warnings,
    #userId: _f$userId,
    #searchDate: _f$searchDate,
    #queryHash: _f$queryHash,
  };

  static DiscourseSearch _instantiate(DecodingData data) {
    return DiscourseSearch(
        searchId: data.dec(_f$searchId),
        resultCount: data.dec(_f$resultCount),
        searchType: data.dec(_f$searchType),
        searchQuery: data.dec(_f$searchQuery),
        searchConstraints: data.dec(_f$searchConstraints),
        searchOrder: data.dec(_f$searchOrder),
        searchGrouping: data.dec(_f$searchGrouping),
        warnings: data.dec(_f$warnings),
        userId: data.dec(_f$userId),
        searchDate: data.dec(_f$searchDate),
        queryHash: data.dec(_f$queryHash));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscourseSearch fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscourseSearch>(map);
  }

  static DiscourseSearch fromJson(String json) {
    return ensureInitialized().decodeJson<DiscourseSearch>(json);
  }
}

mixin DiscourseSearchMappable {
  String toJson() {
    return DiscourseSearchMapper.ensureInitialized()
        .encodeJson<DiscourseSearch>(this as DiscourseSearch);
  }

  Map<String, dynamic> toMap() {
    return DiscourseSearchMapper.ensureInitialized()
        .encodeMap<DiscourseSearch>(this as DiscourseSearch);
  }

  DiscourseSearchCopyWith<DiscourseSearch, DiscourseSearch, DiscourseSearch>
      get copyWith => _DiscourseSearchCopyWithImpl<DiscourseSearch, DiscourseSearch>(
          this as DiscourseSearch, $identity, $identity);
  @override
  String toString() {
    return DiscourseSearchMapper.ensureInitialized()
        .stringifyValue(this as DiscourseSearch);
  }

  @override
  bool operator ==(Object other) {
    return DiscourseSearchMapper.ensureInitialized()
        .equalsValue(this as DiscourseSearch, other);
  }

  @override
  int get hashCode {
    return DiscourseSearchMapper.ensureInitialized()
        .hashValue(this as DiscourseSearch);
  }
}

extension DiscourseSearchValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscourseSearch, $Out> {
  DiscourseSearchCopyWith<$R, DiscourseSearch, $Out> get $asDiscourseSearch =>
      $base.as((v, t, t2) => _DiscourseSearchCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscourseSearchCopyWith<$R, $In extends DiscourseSearch, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get searchConstraints;
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>? get warnings;
  $R call(
      {int? searchId,
      int? resultCount,
      String? searchType,
      String? searchQuery,
      List<dynamic>? searchConstraints,
      String? searchOrder,
      bool? searchGrouping,
      List<dynamic>? warnings,
      int? userId,
      int? searchDate,
      String? queryHash});
  DiscourseSearchCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DiscourseSearchCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscourseSearch, $Out>
    implements DiscourseSearchCopyWith<$R, DiscourseSearch, $Out> {
  _DiscourseSearchCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscourseSearch> $mapper =
      DiscourseSearchMapper.ensureInitialized();
  @override
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get searchConstraints => $value.searchConstraints != null
          ? ListCopyWith(
              $value.searchConstraints!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(searchConstraints: v))
          : null;
  @override
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get warnings => $value.warnings != null
          ? ListCopyWith(
              $value.warnings!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(warnings: v))
          : null;
  @override
  $R call(
          {int? searchId,
          Object? resultCount = $none,
          Object? searchType = $none,
          Object? searchQuery = $none,
          Object? searchConstraints = $none,
          Object? searchOrder = $none,
          Object? searchGrouping = $none,
          Object? warnings = $none,
          Object? userId = $none,
          Object? searchDate = $none,
          Object? queryHash = $none}) =>
      $apply(FieldCopyWithData({
        if (searchId != null) #searchId: searchId,
        if (resultCount != $none) #resultCount: resultCount,
        if (searchType != $none) #searchType: searchType,
        if (searchQuery != $none) #searchQuery: searchQuery,
        if (searchConstraints != $none) #searchConstraints: searchConstraints,
        if (searchOrder != $none) #searchOrder: searchOrder,
        if (searchGrouping != $none) #searchGrouping: searchGrouping,
        if (warnings != $none) #warnings: warnings,
        if (userId != $none) #userId: userId,
        if (searchDate != $none) #searchDate: searchDate,
        if (queryHash != $none) #queryHash: queryHash
      }));
  @override
  DiscourseSearch $make(CopyWithData data) => DiscourseSearch(
      searchId: data.get(#searchId, or: $value.searchId),
      resultCount: data.get(#resultCount, or: $value.resultCount),
      searchType: data.get(#searchType, or: $value.searchType),
      searchQuery: data.get(#searchQuery, or: $value.searchQuery),
      searchConstraints:
          data.get(#searchConstraints, or: $value.searchConstraints),
      searchOrder: data.get(#searchOrder, or: $value.searchOrder),
      searchGrouping: data.get(#searchGrouping, or: $value.searchGrouping),
      warnings: data.get(#warnings, or: $value.warnings),
      userId: data.get(#userId, or: $value.userId),
      searchDate: data.get(#searchDate, or: $value.searchDate),
      queryHash: data.get(#queryHash, or: $value.queryHash));

  @override
  DiscourseSearchCopyWith<$R2, DiscourseSearch, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DiscourseSearchCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
