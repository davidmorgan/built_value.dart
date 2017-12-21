import 'dart:async';

import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:built_value_analyzer_plugin/logger.dart';

int count = 0;

class BuiltValueDriver implements AnalysisDriverGeneric {
  final AnalysisDriver driver;
  final AnalysisDriverScheduler scheduler;
  final PluginCommunicationChannel channel;

  bool hasBv;

  Set<String> files = new Set<String>();

  BuiltValueDriver(this.driver, this.scheduler, this.channel) {
    scheduler.add(this);
    hasBv = driver.sourceFactory
            .resolveUri(null, 'package:built_value/built_value.dart') !=
        null;
    log('hasBv: $hasBv');
  }

  @override
  void addFile(String path) {
    log('addFile $path');
    files.add(path);
    scheduler.notify(this);
  }

  @override
  void dispose() {
    log('dispose');
    // TODO: implement dispose
  }

  // TODO: implement hasFilesToAnalyze
  @override
  bool get hasFilesToAnalyze {
    log('hasFilesToAnalyze');
    return files.isNotEmpty;
  }

  @override
  Future<Null> performWork() {
    log('performWork');
    for (final file in files) {
      if (!file.endsWith('.dart')) continue;
      log('getResult for $file');

      // ignore: unawaited_futures
      ++count;
      log('up: $count');
      driver.getResult(file).then((result) {
        --count;
        log('down: $count');
        log('result for $file');
        for (final compilationUnit in result.libraryElement.units) {
          for (final type in compilationUnit.types) {
            log('checking ${type.displayName}');
            for (final interface in type.interfaces) {
              log('has interface ${interface.displayName}');

              final expectedInterface =
                  'Built<${type.displayName}, ${type.displayName}Builder>';

              if (interface.displayName.startsWith('Built<') &&
                  interface.displayName != expectedInterface) {
                final node = type.computeNode();

                final lineInfo = compilationUnit.lineInfo;
                final offsetLineLocation = lineInfo.getLocation(node.offset);
                channel.sendNotification(new AnalysisErrorsParams(file, [
                  new AnalysisError(
                      AnalysisErrorSeverity.INFO,
                      AnalysisErrorType.HINT,
                      new Location(
                          file,
                          node.offset,
                          node.length,
                          offsetLineLocation.lineNumber,
                          offsetLineLocation.columnNumber),
                      'Wrong implements.',
                      'whee',
                      correction: 'correctMe',
                      hasFix: true)
                ]).toNotification());
                log('*** need to fix $file');
              }
            }
          }
        }
      });
      /*if (dartResult == null) {
        log('was null');
        continue;
      }

      dartResult.libraryElement.importedLibraries
          .forEach((library) => log(library.displayName));*/

      /*channel.sendNotification(new AnalysisErrorsParams(file, [
        new AnalysisError(
            AnalysisErrorSeverity.ERROR,
            AnalysisErrorType.SYNTACTIC_ERROR,
            new Location(file, 0, 10, 2, 3),
            'foo bar baz',
            'whee')
      ]).toNotification());*/
    }
    files.clear();
    return new Future.value(null);
  }

  @override
  set priorityFiles(List<String> priorityPaths) {
    log('priorityFiles');
  }

  // TODO: implement workPriority
  @override
  AnalysisDriverPriority get workPriority {
    log('workPriority');
    return files.isEmpty
        ? AnalysisDriverPriority.nothing
        : AnalysisDriverPriority.interactive;
  }
}
