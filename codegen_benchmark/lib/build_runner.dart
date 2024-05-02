import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'workspace.dart';

class BuildRunner {
  Process? process;

  Completer<void>? _completer;

  void receive(String string) {
    if (_completer != null) {
      if (string.contains('Succeeded')) {
        _completer!.complete();
        _completer = null;
      }
    }
  }

  Future<int> timeSuccess() async {
    if (_completer != null) throw 'already waiting';
    final stopwatch = Stopwatch()..start();
    _completer = Completer<void>();
    await _completer!.future;
    return stopwatch.elapsedMilliseconds;
  }

  Future<void> start(Workspace workspace) async {
    process = await Process.start(
      'dart',
      [
        'run',
        'build_runner',
        'watch',
        '--enable-experiment=macros',
      ],
      workingDirectory: workspace.packagePath,
    );

    var outLines = process!.stdout.transform(utf8.decoder);
    outLines.listen(receive);

    var errLines = process!.stderr.transform(utf8.decoder);
    errLines.listen((l) => print('build_runner stderr: $l'));
  }

  Future<void> close() async {
    if (process != null) {
      process!.kill();
      await process!.exitCode;
    }
  }
}
