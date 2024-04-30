import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'workspace.dart';

class AnalysisServer {
  late Process process;

  Completer<void>? _completer;
  bool Function(Object)? _matcher;

  void send(String message) {
    print('==> $message');
    process.stdin.write('Content-Length: ${message.length}\r\n'
        'Content-Type: application/vscode-jsonrpc;charset=utf8\r\n'
        '\r\n'
        '$message');
  }

  void receive(String message) {
    print('receive: $message');
    if (_matcher != null) {
      final data = json.decode(message) as Object;
      print('here');
      if (_matcher!(data)) {
        _completer!.complete();
        _matcher = null;
        _completer = null;
      }
    }
  }

  Future<int> timeWaitForMessageMs(bool Function(Object) matcher) async {
    if (_matcher != null) throw StateError('Already waiting!');
    final stopwatch = Stopwatch()..start();
    _matcher = matcher;
    _completer = Completer<void>();
    await Future.delayed(Duration(seconds: 30));
    await _completer!.future;
    return stopwatch.elapsedMilliseconds;
  }

  Future<void> start(Workspace workspace) async {
    Directory('${workspace.directory.path}/working').createSync();
    process = await Process.start(
      'dart',
      [
        'language-server',
        '--client-id=codegen_benchmark',
        '--client-version=0.1',
        '--cache=${workspace.directory.path}/working/cache',
        '--packages=${workspace.directory.path}/.dart_tool/package_config.json',
        '--protocol=lsp',
        '--protocol-traffic-log=${workspace.directory.path}/working/protocol-traffic.log',
        '--analysis-driver-log=${workspace.directory.path}/working/analysis-driver.log',
      ],
    );

    var outLines = process.stdout.transform(utf8.decoder);
    outLines.listen(receive);

    send(''
        '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{'
        '"processId":${pid},'
        '"rootPath":"${workspace.packagePath}",'
        '"rootUri":"${workspace.packageUri}",'
        '"capabilities":{}'
        '}}');
    send(''
        '{"jsonrpc":"2.0","method":"initialized","params":{}');
  }
}
