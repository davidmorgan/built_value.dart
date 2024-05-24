import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/context_builder.dart';
import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:async/async.dart';
import 'package:dart_model/model.dart';
import 'package:dart_model/query.dart';
import 'package:dart_model_analyzer_host/dart_model_analyzer_host.dart';

class DartModelRepl {
  final _stdinLines =
      StreamQueue(LineSplitter().bind(Utf8Decoder().bind(stdin)));
  Host? host;

  Future<void> run() async {
    print(''''
Welcome to ${green}package:code_model_repl$reset!
''');

    while (await readInput()) {}
  }

  Future<bool> readInput() async {
    if (host == null) {
      print('No host running; try "analyze <workspace>".');
    }

    stdout.write('> ');
    final line = await _stdinLines.next;
    if (line == 'exit') return false;
    if (line == 'help') {
      printHelp();
      return true;
    }

    if (line.startsWith('analyze ')) {
      createAnalyzer(line.substring('analyze '.length));
      return true;
    }

    if (line.startsWith('query ')) {
      final rest = line.substring('query '.length);
      final maybeQualifiedName = QualifiedName.tryParse(rest);
      final query = maybeQualifiedName == null
          ? Query.uri(rest)
          : Query.qualifiedName(
              uri: maybeQualifiedName.uri, name: maybeQualifiedName.name);
      final model = await host!.query(query);
      print(model.prettyPrint());
      return true;
    }

    if (line.startsWith('watch ')) {
      final rest = line.substring('watch '.length);
      final maybeQualifiedName = QualifiedName.tryParse(rest);
      final query = maybeQualifiedName == null
          ? Query.uri(rest)
          : Query.qualifiedName(
              uri: maybeQualifiedName.uri, name: maybeQualifiedName.name);
      final model = Model();
      (await host!.watch(query)).listen((delta) {
        delta.update(model);
        print('=== current model for $query');
        print(model.prettyPrint());
        print('=== due to delta for $query');
        print(delta.prettyPrint());
      });
      return true;
    }

    print('Unrecognized input. Try "help"?');
    return true;
  }

  void printHelp() {
    print('''
analyze <workspace path>
    Starts the analyzer query backend on <workspace path>.
query <URI>[#name]
    Queries the library at the specified URI. If specified, query for
    the scope called "name".
watch <URI>[#name]
    Like "query", but watches and prints changes.
''');
  }

  void createAnalyzer(String workspace) {
    final contextBuilder = ContextBuilder();
    final analysisContext = contextBuilder.createContext(
        contextRoot:
            ContextLocator().locateRoots(includedPaths: [workspace]).first);
    host = DartModelAnalyzerHost(context: analysisContext);
  }
}

final String reset = '\x1b[0m';
final String green = '\x1b[92;1m';
