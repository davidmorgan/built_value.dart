// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:isolate';

import 'package:_fe_analyzer_shared/src/macros/bootstrap.dart';
import 'package:_fe_analyzer_shared/src/macros/executor/serialization.dart';
import 'package:frontend_server/compute_kernel.dart';

void main(List<String> args) async {
  var scriptUri = Uri.base.resolve('test/values_test.dart').toFilePath();
  watch.start();
  var dartToolDir = Directory('.dart_tool/macro_proposal')
    ..createSync(recursive: true);
  var bootstrapFile =
      File(dartToolDir.uri.resolve('bootstrap.dart').toFilePath());
  log('Bootstrapping macro program (${bootstrapFile.path}).');
  var valueUri = Uri.parse('package:value/value.dart');
  var bootstrapContent = bootstrapMacroIsolate({
    valueUri.toString(): {
      'Value': [''],
      'ValueBuilder': [''],
    },
  }, SerializationMode.byteData);
  bootstrapFile.writeAsStringSync(bootstrapContent);
  var bootstrapKernelFile =
      File(bootstrapFile.uri.resolve('bootstrap.dart.dill').toFilePath());

  var feAnalyzerSharedRoot = (await Isolate.resolvePackageUri(
          Uri.parse('package:_fe_analyzer_shared/fake.dart')))!
      .resolve('./');

  log('Compiling macro program to kernel (${bootstrapKernelFile.path})');
  var dataClassSnapshot = await computeKernel([
    '--enable-experiment=macros',
    '--no-summary',
    '--no-summary-only',
    '--target=vm',
    '--dart-sdk-summary',
    Uri.base
        .resolve(Platform.resolvedExecutable)
        .resolve('../lib/_internal/vm_platform_strong_product.dill')
        .toFilePath(),
    '--output',
    bootstrapKernelFile.path,
    '--source=${bootstrapFile.path}',
    '--source=lib/value.dart',
    for (var source in await _allSources(feAnalyzerSharedRoot.path))
      '--source=$source',
    '--packages-file=.dart_tool/package_config.json',
  ]);
  if (!dataClassSnapshot.succeeded) {
    log('failed to build data class macro!');
    return;
  }

  var output = File(dartToolDir.uri.resolve('user_main.dill').toFilePath());
  log('Building main program to kernel (${output.path})');
  var snapshotResult = await computeKernel([
    '--enable-experiment=macros',
    '--no-summary',
    '--no-summary-only',
    '--target=vm',
    '--dart-sdk-summary',
    Uri.base
        .resolve(Platform.resolvedExecutable)
        .resolve('../lib/_internal/vm_platform_strong_product.dill')
        .toFilePath(),
    '--output',
    output.path,
    '--source',
    scriptUri,
    '--packages-file=.dart_tool/package_config.json',
    '--enable-experiment=macros',
    '--precompiled-macro-format=kernel',
    '--precompiled-macro',
    '$valueUri;${bootstrapKernelFile.path}',
    '--macro-serialization-mode=bytedata',
    '--input-linked',
    bootstrapKernelFile.path,
  ]);
  if (!snapshotResult.succeeded) {
    log('failed to build!');
    return;
  }
  log('Compiled app, attempting to run:');

  var result = await Process.run(Platform.resolvedExecutable, [output.path]);
  log('''
stdout: ${result.stdout}

stderr: ${result.stderr}

exitCode: ${result.exitCode}
''');
}

Iterable<String> _allSources(String packageRoot) => Directory(packageRoot)
    .listSync(recursive: true)
    .whereType<File>()
    .map((e) => e.path)
    .where((path) => path.endsWith('.dart'));

final watch = Stopwatch();

void log(String message) {
  print('${watch.elapsed}: $message');
}
