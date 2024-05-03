import 'dart:async';
import 'dart:io' hide PathNotFoundException;

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart'
    show PathNotFoundException;
import 'package:ng_client/ng_client.dart';
import 'package:ng_model/augmentation.dart';
import 'package:ng_model/query.dart';
import 'package:ng_model/source.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:watcher/watcher.dart';

import 'analyzer_setup.dart' as analyzer_setup;

class NgHost implements NgService {
  final List<Generator> macros;
  final String workspace;
  final bool output;

  late AnalysisContext context;

  final Map<String, Source> sources = {};

  // The generator being queried.
  late Generator macro;

  final Map<Query, Set<Generator>> subscriptions = {};
  final Map<Query, Set<Generator>> newSubscriptions = {};
  final Map<Generator, List<Augmentation>> augmentations = {};
  final Map<String, String> imports = {};
  Set<String> augmentationsChanged = {};

  late final Watcher watcher;

  DonePrinter donePrinter = DonePrinter()..interrupted = true;

  NgHost({required this.macros, required this.workspace, required this.output});

  String get packageName => workspace.substring(workspace.lastIndexOf('/') + 1);

  Future<void> run() async {
    print('Hosting macros: ${macros.map((m) => m.runtimeType).join(', ')}');
    print('Running for workspace: $workspace');
    context = await analyzer_setup.createDriver(workspace: workspace);

    watcher = DirectoryWatcher(workspace);

    await _startMacros();

    final pathsStreamController = StreamController<List<String>>();
    pathsStreamController.add(Directory(workspace)
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path)
        .where((p) =>
            p.endsWith('.dart') &&
            !p.endsWith('.ng.dart') &&
            !p.endsWith('.bv.dart'))
        .toList());
    pathsStreamController.addStream(watcher.events
        .map((e) => e.path)
        .where((p) =>
            p.endsWith('.dart') &&
            !p.endsWith('.ng.dart') &&
            !p.endsWith('.bv.dart'))
        .debounceBuffer(Duration(milliseconds: 20)));

    await for (var paths in pathsStreamController.stream) {
      donePrinter.interrupted = true;
      final newSources = await _analyzeSource(paths.toSet().toList());
      for (final path in paths) {
        final sourceChanges =
            newSources[path]?.subtract(sources[path] ?? Source());
        if (sourceChanges == null) continue;
        print('Changes: $sourceChanges');
        sources[path] = newSources[path]!;
        if (sourceChanges.isNotEmpty) print(sourceChanges);
        _sendChanges(sourceChanges, subscriptions, macros);
        while (true) {
          final workingSubscriptions = Map.of(newSubscriptions);
          subscriptions.addAll(workingSubscriptions);
          newSubscriptions.clear();

          _sendChanges(sourceChanges, workingSubscriptions, macros);
          if (newSubscriptions.isEmpty) {
            break;
          }
        }
      }

      for (final macro in macros) {
        this.macro = macro;
        macro.flush(this);
      }
      _writeAugmentations();
      donePrinter = DonePrinter();
    }
  }

  void _sendChanges(Iterable<SourceChange> sourceChanges,
      Map<Query, Set<Generator>> subscriptions, Iterable<Generator> macros) {
    final changesToSend = <Generator, Set<SourceChange>>{};
    macros = Set.identity()..addAll(macros);
    for (final query in subscriptions.keys) {
      final matchingChanges = sourceChanges
          .where((c) =>
              query.matchesIdentifier(c.identifier) &&
              query.matchesEntity(c.entity))
          .toList();
      if (matchingChanges.isNotEmpty) {
        for (final macro in subscriptions[query]!) {
          if (!macros.contains(macro)) continue;
          changesToSend[macro] ??= Set.identity();
          changesToSend[macro]!.addAll(matchingChanges);
        }
      }
    }

    for (final macro in changesToSend.keys) {
      print('Sending changes to $macro:');
      this.macro = macro;
      for (final change in changesToSend[macro]!) {
        print('  Sending: $change');
        macro.notify(this, change);
      }
    }
  }

  Future<void> _startMacros() async {
    for (final macro in macros) {
      this.macro = macro;
      macro.start(this);
    }
  }

  bool first = true;
  Future<Map<String, Source>> _analyzeSource(List<String> paths) async {
    for (final path in paths) {
      context.changeFile(path);
    }
    await context.applyPendingFileChanges();

    final result = <String, Source>{};
    for (final path in paths) {
      final sourceChanges = <SourceChange>[];
      final maybeResolvedLibrary =
          await context.currentSession.getResolvedLibrary(path);
      if (maybeResolvedLibrary is! ResolvedLibraryResult) continue;
      final element = maybeResolvedLibrary.element;
      final uri = element.source.uri.toString();
      try {
        imports[uri] = element.definingCompilationUnit.source.contents.data
            .split('\n')
            .where((l) =>
                l.startsWith('import ') && !l.startsWith('import augment'))
            .join('\n');

        for (final element in element.topLevelElements) {
          if (element is ClassElement) {
            if (element.isAugmentation) continue;
            final annotations = element.metadata.map((m) {
              return m.toSource();
            }).toList();
            // TODO(davidmorgan): list, not toString().
            sourceChanges.add(SourceChangeAdd(
                Identifier(uri, element.name, null),
                Entity(
                    {'type': 'class', 'annotations': annotations.toString()})));
            for (final method in element.methods) {
              sourceChanges.add(SourceChangeAdd(
                  Identifier(uri, element.name, method.name),
                  Entity({'type': 'method'})));
            }
            for (final field in element.fields) {
              sourceChanges.add(SourceChangeAdd(
                  Identifier(uri, element.name, field.name),
                  Entity({
                    'type': 'field',
                    if (field.getter != null)
                      'fieldType': field.getter!.returnType
                          .getDisplayString(withNullability: true)
                  })));
            }
          }
        }
        result[path] = Source()..applyAll(sourceChanges);
      } on PathNotFoundException {
        // It was deleted.
      }
    }
    return result;
  }

  void _writeAugmentations() {
    if (augmentationsChanged.isEmpty) return;
    final augmentations = this
        .augmentations
        .values
        .expand((e) => e)
        .where((a) => augmentationsChanged.contains(a.uri))
        .toList();
    final augmentationsByUri = <String, List<Augmentation>>{};
    for (final augmentation in augmentations) {
      final uri = augmentation.uri;
      augmentationsByUri[uri] ??= [];
      augmentationsByUri[uri]!.add(augmentation);
    }
    for (final uri in augmentationsByUri.keys) {
      final outputPath = uri
          .replaceAll('package:$packageName', '$workspace/lib')
          .replaceAll('.dart', '.ng.dart');
      final basePath = uri.replaceAll('package:$packageName/', '');
      final augmentations = augmentationsByUri[uri]!;
      final output = "augment library '$basePath';\n" + imports[uri]!;
      if (this.output)
        File(outputPath).writeAsStringSync(
            output + Augmentation.mergeToSource(augmentations));
    }
    augmentationsChanged.clear();
  }

  @override
  void subscribe(Query query) {
    print('$macro subscribed to $query.');
    newSubscriptions[query] ??= Set.identity();
    newSubscriptions[query]!.add(macro);
  }

  @override
  void unsubscribe(Query query) {
    print('$macro unsubscribed from $query.');
    subscriptions[query]?.remove(macro);
  }

  @override
  void emit(Augmentation augmentation) {
    print('+$augmentation');
    augmentations[macro] ??= [];
    augmentations[macro]!.add(augmentation);
    augmentationsChanged.add(augmentation.uri);
  }

  @override
  void unemit(Augmentation augmentation) {
    print('-$augmentation');
    augmentations[macro]?.remove(augmentation);
    augmentationsChanged.add(augmentation.uri);
  }

  @override
  void unemitAll(String uri) {
    print('-clear augmentations for $macro and $uri');
    augmentations[macro]?.removeWhere((a) => a.uri == uri);
    augmentationsChanged.add(uri);
  }
}

class DonePrinter {
  bool interrupted = false;

  DonePrinter() {
    Future.delayed(Duration(milliseconds: 21)).then((_) {
      if (!interrupted) print('Done for now!');
    });
  }
}
