import 'source.dart';

class Query {
  final String _description;
  final bool Function(Identifier identifier)? _identifierMatcher;
  final bool Function(Entity entity)? _entityMatcher;

  Query.classesWithAnnotation(String name)
      : _description = 'classesWithAnnotation($name)',
        _identifierMatcher = null,
        _entityMatcher =
            // TODO(davidmorgan): String->List.
            ((e) => e['type'] == 'class' && e['annotations'] == '[$name]');

  Query.fieldsOf(Identifier identifier)
      : _description = 'methodsOf($identifier)',
        _identifierMatcher = ((i) => i.matchesIgnoringMember(identifier)),
        _entityMatcher = ((e) => e['type'] == 'field');

  bool matches(SourceChange change) =>
      matchesIdentifier(change.identifier) &&
      (matchesEntity(change.entity) ||
          (change is SourceChangeEdit && matchesEntity(change.old)));

  bool matchesIdentifier(Identifier identifier) =>
      _identifierMatcher == null ? true : _identifierMatcher(identifier);

  bool matchesEntity(Entity entity) =>
      _entityMatcher == null ? true : _entityMatcher(entity);

  String toString() => _description;
}
