import 'package:ng_client/ng_client.dart';
import 'package:ng_model/augmentation.dart';
import 'package:ng_model/query.dart';
import 'package:ng_model/source.dart';

class ToStringGeneratorNg implements Generator {
  final Map<Identifier, List<String>> fields = {};

  final Query classesWithAnnotation =
      Query.classesWithAnnotation('@ToString()');

  @override
  void start(NgService service) {
    service.subscribe(classesWithAnnotation);
  }

  @override
  void notify(NgService service, SourceChange change) {
    if (classesWithAnnotation.matches(change)) {
      if (change is SourceChangeAdd || change is SourceChangeEdit) {
        service.subscribe(Query.fieldsOf(change.identifier));
        fields[change.identifier] = [];
        toEmit.add(change.identifier.uri);
      } else if (change is SourceChangeRemove) {
        service.unsubscribe(Query.fieldsOf(change.identifier));
        fields.remove([change.identifier]);
        toEmit.add(change.identifier.uri);
      }
    } else if (change.entity['type'] == 'field') {
      final field = change.identifier.member!;
      if (change is SourceChangeAdd) {
        fields[change.identifier.withoutMember]!.add(field);
      } else if (change is SourceChangeRemove) {
        fields[change.identifier.withoutMember]!.remove(field);
      } else {
        fields[change.identifier.withoutMember]!.remove(field);
        fields[change.identifier.withoutMember]!.add(field);
      }
      toEmit.add(change.identifier.uri);
    }
  }

  final toEmit = <String>{};
  void flush(NgService service) {
    emit(service, toEmit);
    toEmit.clear();
  }

  void emit(NgService service, Iterable<String> toEmit) {
    for (final uri in toEmit) {
      service.unemitAll(uri);

      for (final identifier in fields.keys.where((i) => i.uri == uri)) {
        final result = StringBuffer();
        result.writeln('augment class ${identifier.name} {');
        result.writeln([
          "toString() => '\${",
          identifier.name,
          '}(',
          for (final field in fields[identifier]!) ...[
            field,
            ': \$',
            field,
            if (field != fields[identifier]!.last) ', ',
          ],
          ")';",
        ].join(''));
        result.write('}');
        service.emit(Augmentation.code(identifier.uri, result.toString()));
      }
    }
  }

  @override
  String toString() => 'ToStringGeneratorNg';
}
