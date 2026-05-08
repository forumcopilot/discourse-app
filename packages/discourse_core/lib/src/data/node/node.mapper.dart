// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'node.dart';

class DiscourseNodeMapper extends ClassMapperBase<DiscourseNode> {
  DiscourseNodeMapper._();

  static DiscourseNodeMapper? _instance;
  static DiscourseNodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscourseNodeMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DiscourseNode';

  static List<Map<String, dynamic>>? _$breadcrumbs(DiscourseNode v) =>
      v.breadcrumbs;
  static const Field<DiscourseNode, List<Map<String, dynamic>>> _f$breadcrumbs =
      Field('breadcrumbs', _$breadcrumbs, opt: true);
  static Map<String, dynamic>? _$typeData(DiscourseNode v) => v.typeData;
  static const Field<DiscourseNode, Map<String, dynamic>> _f$typeData =
      Field('typeData', _$typeData, opt: true);
  static String? _$viewUrl(DiscourseNode v) => v.viewUrl;
  static const Field<DiscourseNode, String> _f$viewUrl =
      Field('viewUrl', _$viewUrl, opt: true);
  static int _$nodeId(DiscourseNode v) => v.nodeId;
  static const Field<DiscourseNode, int> _f$nodeId = Field('nodeId', _$nodeId);
  static String? _$title(DiscourseNode v) => v.title;
  static const Field<DiscourseNode, String> _f$title =
      Field('title', _$title, opt: true);
  static String? _$nodeName(DiscourseNode v) => v.nodeName;
  static const Field<DiscourseNode, String> _f$nodeName =
      Field('nodeName', _$nodeName, opt: true);
  static String? _$description(DiscourseNode v) => v.description;
  static const Field<DiscourseNode, String> _f$description =
      Field('description', _$description, opt: true);
  static String? _$nodeTypeId(DiscourseNode v) => v.nodeTypeId;
  static const Field<DiscourseNode, String> _f$nodeTypeId =
      Field('nodeTypeId', _$nodeTypeId, opt: true);
  static int? _$parentNodeId(DiscourseNode v) => v.parentNodeId;
  static const Field<DiscourseNode, int> _f$parentNodeId =
      Field('parentNodeId', _$parentNodeId, opt: true);
  static int? _$displayOrder(DiscourseNode v) => v.displayOrder;
  static const Field<DiscourseNode, int> _f$displayOrder =
      Field('displayOrder', _$displayOrder, opt: true);
  static bool? _$displayInList(DiscourseNode v) => v.displayInList;
  static const Field<DiscourseNode, bool> _f$displayInList =
      Field('displayInList', _$displayInList, opt: true);

  @override
  final MappableFields<DiscourseNode> fields = const {
    #breadcrumbs: _f$breadcrumbs,
    #typeData: _f$typeData,
    #viewUrl: _f$viewUrl,
    #nodeId: _f$nodeId,
    #title: _f$title,
    #nodeName: _f$nodeName,
    #description: _f$description,
    #nodeTypeId: _f$nodeTypeId,
    #parentNodeId: _f$parentNodeId,
    #displayOrder: _f$displayOrder,
    #displayInList: _f$displayInList,
  };

  static DiscourseNode _instantiate(DecodingData data) {
    return DiscourseNode(
        breadcrumbs: data.dec(_f$breadcrumbs),
        typeData: data.dec(_f$typeData),
        viewUrl: data.dec(_f$viewUrl),
        nodeId: data.dec(_f$nodeId),
        title: data.dec(_f$title),
        nodeName: data.dec(_f$nodeName),
        description: data.dec(_f$description),
        nodeTypeId: data.dec(_f$nodeTypeId),
        parentNodeId: data.dec(_f$parentNodeId),
        displayOrder: data.dec(_f$displayOrder),
        displayInList: data.dec(_f$displayInList));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscourseNode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscourseNode>(map);
  }

  static DiscourseNode fromJson(String json) {
    return ensureInitialized().decodeJson<DiscourseNode>(json);
  }
}

mixin DiscourseNodeMappable {
  String toJson() {
    return DiscourseNodeMapper.ensureInitialized()
        .encodeJson<DiscourseNode>(this as DiscourseNode);
  }

  Map<String, dynamic> toMap() {
    return DiscourseNodeMapper.ensureInitialized()
        .encodeMap<DiscourseNode>(this as DiscourseNode);
  }

  DiscourseNodeCopyWith<DiscourseNode, DiscourseNode, DiscourseNode> get copyWith =>
      _DiscourseNodeCopyWithImpl<DiscourseNode, DiscourseNode>(
          this as DiscourseNode, $identity, $identity);
  @override
  String toString() {
    return DiscourseNodeMapper.ensureInitialized()
        .stringifyValue(this as DiscourseNode);
  }

  @override
  bool operator ==(Object other) {
    return DiscourseNodeMapper.ensureInitialized()
        .equalsValue(this as DiscourseNode, other);
  }

  @override
  int get hashCode {
    return DiscourseNodeMapper.ensureInitialized().hashValue(this as DiscourseNode);
  }
}

extension DiscourseNodeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscourseNode, $Out> {
  DiscourseNodeCopyWith<$R, DiscourseNode, $Out> get $asDiscourseNode =>
      $base.as((v, t, t2) => _DiscourseNodeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscourseNodeCopyWith<$R, $In extends DiscourseNode, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Map<String, dynamic>,
          ObjectCopyWith<$R, Map<String, dynamic>, Map<String, dynamic>>>?
      get breadcrumbs;
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get typeData;
  $R call(
      {List<Map<String, dynamic>>? breadcrumbs,
      Map<String, dynamic>? typeData,
      String? viewUrl,
      int? nodeId,
      String? title,
      String? nodeName,
      String? description,
      String? nodeTypeId,
      int? parentNodeId,
      int? displayOrder,
      bool? displayInList});
  DiscourseNodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DiscourseNodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscourseNode, $Out>
    implements DiscourseNodeCopyWith<$R, DiscourseNode, $Out> {
  _DiscourseNodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscourseNode> $mapper =
      DiscourseNodeMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Map<String, dynamic>,
          ObjectCopyWith<$R, Map<String, dynamic>, Map<String, dynamic>>>?
      get breadcrumbs => $value.breadcrumbs != null
          ? ListCopyWith(
              $value.breadcrumbs!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(breadcrumbs: v))
          : null;
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get typeData => $value.typeData != null
          ? MapCopyWith(
              $value.typeData!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(typeData: v))
          : null;
  @override
  $R call(
          {Object? breadcrumbs = $none,
          Object? typeData = $none,
          Object? viewUrl = $none,
          int? nodeId,
          Object? title = $none,
          Object? nodeName = $none,
          Object? description = $none,
          Object? nodeTypeId = $none,
          Object? parentNodeId = $none,
          Object? displayOrder = $none,
          Object? displayInList = $none}) =>
      $apply(FieldCopyWithData({
        if (breadcrumbs != $none) #breadcrumbs: breadcrumbs,
        if (typeData != $none) #typeData: typeData,
        if (viewUrl != $none) #viewUrl: viewUrl,
        if (nodeId != null) #nodeId: nodeId,
        if (title != $none) #title: title,
        if (nodeName != $none) #nodeName: nodeName,
        if (description != $none) #description: description,
        if (nodeTypeId != $none) #nodeTypeId: nodeTypeId,
        if (parentNodeId != $none) #parentNodeId: parentNodeId,
        if (displayOrder != $none) #displayOrder: displayOrder,
        if (displayInList != $none) #displayInList: displayInList
      }));
  @override
  DiscourseNode $make(CopyWithData data) => DiscourseNode(
      breadcrumbs: data.get(#breadcrumbs, or: $value.breadcrumbs),
      typeData: data.get(#typeData, or: $value.typeData),
      viewUrl: data.get(#viewUrl, or: $value.viewUrl),
      nodeId: data.get(#nodeId, or: $value.nodeId),
      title: data.get(#title, or: $value.title),
      nodeName: data.get(#nodeName, or: $value.nodeName),
      description: data.get(#description, or: $value.description),
      nodeTypeId: data.get(#nodeTypeId, or: $value.nodeTypeId),
      parentNodeId: data.get(#parentNodeId, or: $value.parentNodeId),
      displayOrder: data.get(#displayOrder, or: $value.displayOrder),
      displayInList: data.get(#displayInList, or: $value.displayInList));

  @override
  DiscourseNodeCopyWith<$R2, DiscourseNode, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DiscourseNodeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
