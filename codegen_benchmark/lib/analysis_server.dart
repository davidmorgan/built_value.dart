import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';

import 'random.dart';
import 'workspace.dart';

class AnalysisServer {
  final Workspace workspace;
  late Process process;

  Completer<void>? _completer;
  bool Function(Object)? _matcher;
  Map<String, List<String>> diagnostics = {};

  AnalysisServer({required this.workspace});

  void send(String message) {
    process.stdin.write('Content-Length: ${message.length}\r\n'
        'Content-Type: application/vscode-jsonrpc;charset=utf8\r\n'
        '\r\n'
        '$message');
  }

  void receive(String message) {
    final data = json.decode(message) as Object;
    if (data is Map && data['method'] == 'textDocument/publishDiagnostics') {
      final uri = data['params']['uri'] as String;
      final list = data['params']['diagnostics'] as List;
      if (list.isEmpty) {
        diagnostics.remove(uri);
      } else {
        diagnostics[uri] = [];
        for (final diagnostic in list) {
          diagnostics[uri]!.add(diagnostic['code']);
        }
      }
    }

    /*if (data is Map &&
        data['result'] != null &&
        data['result'].containsKey('capabilities')) {
      send(
          '{"jsonrpc":"2.0","method":"workspace/didChangeConfiguration","params":{"settings":null}}');
    }*/

    if (_matcher != null) {
      if (_matcher!(data)) {
        _completer!.complete();
        _matcher = null;
        _completer = null;
      }
    }
  }

  Future<int> _timeWaitForMessageMs(bool Function(Object) matcher) async {
    if (_matcher != null) throw StateError('Already waiting!');
    final stopwatch = Stopwatch()..start();
    _matcher = matcher;
    _completer = Completer<void>();
    await _completer!.future;
    return stopwatch.elapsedMilliseconds;
  }

  Future<void> waitForAnalysis() async {
    final sentinelName = 'sentinel$largeRandom.dart';
    workspace.write(sentinelName, source: '/*');
    await _timeWaitForMessageMs((json) =>
        json is Map &&
        json['method'] == 'textDocument/publishDiagnostics' &&
        json['params']['uri'].contains(sentinelName) &&
        json['params']['diagnostics'].isNotEmpty);
    workspace.delete(sentinelName);
    await _timeWaitForMessageMs((json) =>
        json is Map &&
        json['method'] == 'textDocument/publishDiagnostics' &&
        json['params']['uri'].contains(sentinelName) &&
        json['params']['diagnostics'].isEmpty);
  }

  Future<void> start() async {
    workspace.write('analysis_options.yaml', source: '''
analyzer:
  enable-experiment:
    - macros
''');
    Directory('${workspace.directory.path}/working').createSync();
    process = await Process.start(
      'dart',
      [
        'language-server',
        // '--enable-experiment=macros',
        '--client-id=codegen_benchmark',
        '--client-version=0.1',
        '--cache=${workspace.directory.path}/working/cache',
        '--packages=${workspace.packagePath}/.dart_tool/package_config.json',
        '--protocol=lsp',
        '--protocol-traffic-log=${workspace.directory.path}/working/protocol-traffic.log',
        '--analysis-driver-log=${workspace.directory.path}/working/analysis-driver.log',
      ],
    );

    process.stdout.transform(LspPacketTransformer()).listen(receive);

    var errLines = process.stderr.transform(utf8.decoder);
    errLines.listen((l) => print('analysis server stderr: $l'));

    send(''
        '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{'
        '"processId":${pid},'
        '"rootPath":"${workspace.packagePath}",'
        '"rootUri":"${workspace.packageUri}",'
        '"capabilities":{}'
        '}}');
    send(''
        '{"jsonrpc":"2.0","method":"initialized","params":{}}');
  }

  Future<void> close() async {
    process.kill();
    await process.exitCode;
  }
}

// copied from package:analysis_server

class InvalidEncodingError {
  final String headers;
  InvalidEncodingError(this.headers);

  @override
  String toString() =>
      'Encoding in supplied headers is not supported.\n\nHeaders:\n$headers';
}

class LspHeaders {
  final String rawHeaders;
  final int contentLength;
  final String? encoding;
  LspHeaders(this.rawHeaders, this.contentLength, this.encoding);
}

/// Transforms a stream of LSP data in the form:
///
///     Content-Length: xxx\r\n
///     Content-Type: application/vscode-jsonrpc; charset=utf-8\r\n
///     \r\n
///     { JSON payload }
///
/// into just the JSON payload, decoded with the specified encoding. Line endings
/// for headers must be \r\n on all platforms as defined in the LSP spec.
class LspPacketTransformer extends StreamTransformerBase<List<int>, String> {
  @override
  Stream<String> bind(Stream<List<int>> stream) {
    LspHeaders? headersState;
    var buffer = <int>[];
    var controller = MoreTypedStreamController<String,
        _LspPacketTransformerListenData, _LspPacketTransformerPauseData>(
      onListen: (controller) {
        var input = stream.expand((b) => b).listen(
          (codeUnit) {
            buffer.add(codeUnit);
            var headers = headersState;
            if (headers == null && _endsWithCrLfCrLf(buffer)) {
              headersState = _parseHeaders(buffer);
              buffer.clear();
            } else if (headers != null &&
                buffer.length >= headers.contentLength) {
              // UTF-8 is the default - and only supported - encoding for LSP.
              // The string 'utf8' is valid since it was published in the original spec.
              // Any other encodings should be rejected with an error.
              if ([null, 'utf-8', 'utf8']
                  .contains(headers.encoding?.toLowerCase())) {
                controller.add(utf8.decode(buffer));
              } else {
                controller.addError(InvalidEncodingError(headers.rawHeaders));
              }
              buffer.clear();
              headersState = null;
            }
          },
          onError: controller.addError,
          onDone: controller.close,
        );
        return _LspPacketTransformerListenData(input);
      },
      onPause: (listenData) {
        listenData.input.pause();
        return _LspPacketTransformerPauseData();
      },
      onResume: (listenData, pauseData) => listenData.input.resume(),
      onCancel: (listenData) => listenData.input.cancel(),
    );
    return controller.controller.stream;
  }

  /// Whether [buffer] ends in '\r\n\r\n'.
  static bool _endsWithCrLfCrLf(List<int> buffer) {
    var l = buffer.length;
    return l > 4 &&
        buffer[l - 1] == 10 &&
        buffer[l - 2] == 13 &&
        buffer[l - 3] == 10 &&
        buffer[l - 4] == 13;
  }

  static String? _extractEncoding(String? header) {
    var charset = header
        ?.split(';')
        .map((s) => s.trim().toLowerCase())
        .firstWhereOrNull((s) => s.startsWith('charset='));

    return charset?.split('=')[1];
  }

  /// Decodes [buffer] into a String and returns the 'Content-Length' header value.
  static LspHeaders _parseHeaders(List<int> buffer) {
    // Headers are specified as always ASCII in LSP.
    var asString = ascii.decode(buffer);
    var headers = asString.split('\r\n');
    var lengthHeader =
        headers.firstWhere((h) => h.startsWith('Content-Length'));
    var length = lengthHeader.split(':').last.trim();
    var contentTypeHeader =
        headers.firstWhereOrNull((h) => h.startsWith('Content-Type'));
    var encoding = _extractEncoding(contentTypeHeader);
    return LspHeaders(asString, int.parse(length), encoding);
  }
}

/// The data class for [StreamController.onListen].
class _LspPacketTransformerListenData {
  final StreamSubscription<int> input;

  _LspPacketTransformerListenData(this.input);
}

/// The marker class for [StreamController.onPause].
class _LspPacketTransformerPauseData {}

class MoreTypedStreamController<T, ListenData, PauseData> {
  final StreamController<T> controller;

  /// A wrapper around [StreamController] that statically guarantees its
  /// clients that [onPause] and [onCancel] can only be invoked after
  /// [onListen], and [onResume] can only be invoked after [onPause].
  ///
  /// There is no static guarantee that [onPause] will not be invoked twice.
  ///
  /// Internally the wrapper is not safe, and uses explicit null checks.
  factory MoreTypedStreamController({
    required ListenData Function(StreamController<T>) onListen,
    PauseData Function(ListenData)? onPause,
    void Function(ListenData, PauseData)? onResume,
    FutureOr<void> Function(ListenData)? onCancel,
    bool sync = false,
  }) {
    ListenData? listenData;
    PauseData? pauseData;
    var controller = StreamController<T>(
      onPause: () {
        if (pauseData != null) {
          throw StateError('Already paused');
        }
        var local_onPause = onPause;
        if (local_onPause != null) {
          pauseData = local_onPause(listenData as ListenData);
        }
      },
      onResume: () {
        var local_onResume = onResume;
        if (local_onResume != null) {
          var local_pauseData = pauseData as PauseData;
          pauseData = null;
          local_onResume(listenData as ListenData, local_pauseData);
        }
      },
      onCancel: () {
        var local_onCancel = onCancel;
        if (local_onCancel != null) {
          var local_listenData = listenData as ListenData;
          listenData = null;
          local_onCancel(local_listenData);
        }
      },
      sync: sync,
    );
    controller.onListen = () {
      listenData = onListen(controller);
    };
    return MoreTypedStreamController._(controller);
  }

  MoreTypedStreamController._(this.controller);
}
