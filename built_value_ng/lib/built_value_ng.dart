import 'package:ng_client/ng_client.dart';
import 'package:ng_model/augmentation.dart';
import 'package:ng_model/query.dart';
import 'package:ng_model/source.dart';

class BuiltValueNg implements Generator {
  final Query classesWithAnnotation =
      Query.classesWithAnnotation('MyAnnotation');
  @override
  void start(NgService service) {
    service.subscribe(classesWithAnnotation);
  }

  @override
  void notify(NgService service, SourceChange change) {
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
