import 'delta.dart';
import 'model.dart';

extension type Query.fromJson(Map<String, Object?> node) {
  Query({List<Operation>? operations})
      : this.fromJson({'operations': operations ?? <Object?>[]});

  Query.uri(String uri)
      : this(operations: [
          Operation.include([
            Path([uri])
          ])
        ]);

  Query.qualifiedName({required String uri, required String name})
      : this(operations: [
          Operation.include([
            Path([uri, name])
          ])
        ]);

  List<Operation> get operations => node['operations'] as List<Operation>;

  Model query(Model model) {
    Model result = Model();

    for (final operation in operations) {
      if (operation.isInclude) {
        for (final path in operation.paths) {
          if (model.hasPath(path)) {
            final node = model.getAtPath(path);
            result.updateAtPath(path, node);
          }
        }
      } else if (operation.isExclude) {
        for (final path in operation.paths) {
          model.removeAtPath(path);
        }
      } else if (operation.isFollow) {
        // TODO(davidmorgan): implement.
      }
    }

    return result;
  }

  // TODO(davidmorgan): implement properly.
  String get firstUri =>
      operations.firstWhere((o) => o.isInclude).paths[0].path.first;

  String? get firstName {
    final operation = operations.firstWhere((o) => o.isInclude);
    final path = operation.paths[0];
    return path.path.length > 1 ? path.path[1] : null;
  }
}

extension type Operation.fromJson(Map<String, Object?> node) {
  Operation.include(List<Path> include)
      : this.fromJson({'type': 'include', 'paths': include});

  Operation.exclude(List<Path> exclude)
      : this.fromJson({'type': 'exclude', 'paths': exclude});

  Operation.followTypes(int times)
      : this.fromJson({'type': 'followTypes', 'times': times});

  bool get isInclude => node['type'] == 'include';
  bool get isExclude => node['type'] == 'exclude';
  bool get isFollow => node['type'] == 'follow';

  List<Path> get paths => (node['paths'] as List).cast();
}

abstract interface class Host {
  Future<Model> query(Query query);
  Future<Stream<Delta>> watch(Query query);
}
