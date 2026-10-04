/// Discourse's current draft serializer writes `{id?, name}` objects;
/// older clients wrote names directly. The composer submits tag names.
List<String> draftTagNames(Object? value) {
  if (value is! List) return const [];
  final names = <String>{};
  for (final tag in value) {
    final name = tag is String ? tag : (tag is Map ? tag['name'] : null);
    if (name is String && name.trim().isNotEmpty) names.add(name.trim());
  }
  return names.toList(growable: false);
}
