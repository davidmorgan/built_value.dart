import 'package:collection/collection.dart';

class Identifier {
  String uri;
  String name;
  String? member;

  Identifier(this.uri, this.name, this.member);

  operator ==(Object other) =>
      other is Identifier &&
      other.uri == uri &&
      other.name == name &&
      other.member == member;

  Identifier get withoutMember => Identifier(uri, name, null);

  bool matchesIgnoringMember(Identifier other) =>
      other.uri == uri && other.name == name;

  int get hashCode => uri.hashCode ^ name.hashCode ^ member.hashCode;
  String toString() => '$uri/$name${member == null ? '' : '.$member'}';
}

class Entity {
  final Map<String, String> data;

  Entity(this.data);

  operator [](String key) => data[key];

  String toString() =>
      '(' + data.entries.map((e) => '${e.key}: ${e.value}').join(', ') + ')';

  bool operator ==(Object other) =>
      other is Entity && const MapEquality().equals(data, other.data);
}

class Source {
  final Map<Identifier, Entity> _entities = {};

  bool apply(SourceChange sourceChange) => sourceChange.apply(this);

  List<SourceChange> applyAll(Iterable<SourceChange> sourceChanges) =>
      sourceChanges.where((s) => apply(s)).toList();

  List<SourceChange> subtract(Source other) {
    final myIdentifiers = _entities.keys.toSet();
    final otherIdentifiers = other._entities.keys.toSet();
    final result = <SourceChange>[];
    for (final identifier in myIdentifiers) {
      if (!otherIdentifiers.contains(identifier)) {
        result.add(SourceChangeAdd(identifier, _entities[identifier]!));
      } else {
        if (other._entities[identifier] != _entities[identifier]) {
          result.add(SourceChangeEdit(identifier, other._entities[identifier]!,
              _entities[identifier]!));
        }
      }
    }
    for (final identifier in otherIdentifiers) {
      if (!myIdentifiers.contains(identifier)) {
        result
            .add(SourceChangeRemove(identifier, other._entities[identifier]!));
      }
    }
    return result;
  }
}

abstract class SourceChange {
  bool apply(Source source);

  Identifier get identifier;
  Entity get entity;
}

class SourceChangeAdd implements SourceChange {
  final Identifier identifier;
  final Entity entity;

  SourceChangeAdd(this.identifier, this.entity);

  bool apply(Source source) {
    final existingEntity = source._entities[identifier];
    source._entities[identifier] = entity;
    return existingEntity != entity;
  }

  String toString() => 'Add($identifier, $entity)';
}

class SourceChangeRemove implements SourceChange {
  final Identifier identifier;
  final Entity entity;

  SourceChangeRemove(this.identifier, this.entity);

  bool apply(Source source) {
    final existingEntity = source._entities[identifier];
    source._entities.remove(identifier);
    return existingEntity != entity;
  }

  String toString() => 'Remove($identifier, $entity)';
}

class SourceChangeEdit implements SourceChange {
  final Identifier identifier;
  final Entity old;
  final Entity entity;

  SourceChangeEdit(this.identifier, this.old, this.entity);

  bool apply(Source source) {
    final existingEntity = source._entities[identifier];
    source._entities[identifier] = entity;
    return existingEntity != entity;
  }

  String toString() => 'Edit($identifier, $old->$entity)';
}
