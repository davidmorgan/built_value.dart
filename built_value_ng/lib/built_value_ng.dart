import 'package:ng_client/ng_client.dart';
import 'package:ng_model/augmentation.dart';
import 'package:ng_model/query.dart';
import 'package:ng_model/source.dart';

class ExampleMacro implements IncrementalMacro {
  final Query classesWithAnnotation =
      Query.classesWithAnnotation('MyAnnotation');
  @override
  void start(MacroService service) {
    service.subscribe(classesWithAnnotation);
  }

  @override
  void notify(MacroService service, SourceChange change) {
    if (classesWithAnnotation.matches(change)) {
      service.subscribe(Query.methodsOf(change.identifier));
    } else if (change is SourceChangeAdd && change.entity['type'] == 'method') {
      service.emit(Augmentation.classMember(change.identifier.withoutMember,
          'void ${change.identifier.member}_aug() {}'));
    } else if (change is SourceChangeRemove &&
        change.entity['type'] == 'method') {
      service.unemit(Augmentation.classMember(change.identifier.withoutMember,
          'void ${change.identifier.member}_aug() {}'));
    }
  }

  String toString() => 'ExampleMacro';
}
