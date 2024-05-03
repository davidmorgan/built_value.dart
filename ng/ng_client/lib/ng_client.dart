import 'package:ng_model/augmentation.dart';
import 'package:ng_model/query.dart';
import 'package:ng_model/source.dart';

abstract class NgService {
  void subscribe(Query query);
  void unsubscribe(Query query);

  void emit(Augmentation augmentation);
  void unemitAll(String uri);
  void unemit(Augmentation augmentation);
}

abstract class Generator {
  void start(NgService service);

  void notify(NgService service, SourceChange change);
  void flush(NgService service);
}
