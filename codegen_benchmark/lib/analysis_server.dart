import 'dart:convert';
import 'dart:io';

import 'workspace.dart';

class AnalysisServer {
  late Process process;

  Future<void> start(Workspace workspace) async {
    Directory('${workspace.directory.path}/working').createSync();
    process = await Process.start(
      'dart',
      [
        'language-server',
        '--client-id=codegen_benchmark',
        '--cache=${workspace.directory.path}/working/cache}',
        '--packages=${workspace.directory.path}/.dart_tool/package_config.json',
        '--protocol=lsp',
        '--protocol-traffic-log=${workspace.directory.path}/working/protocol-traffic.log',
        '--analysis-driver-log=${workspace.directory.path}/working/analysis-driver.log',
      ],
    );

    var outLines =
        process.stdout.transform(utf8.decoder).transform(const LineSplitter());
    outLines.listen((l) => print(l));

    var errorLines =
        process.stderr.transform(utf8.decoder).transform(const LineSplitter());
    errorLines.listen((l) => print('*** $l'));

    for (var i = 0; i != 10; ++i) {
      print('i $i');
      process.stdin.write('hi!\n');
      await process.stdin.flush();
    }
  }
}
