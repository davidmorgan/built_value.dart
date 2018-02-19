import 'dart:async';

import 'package:build_test/build_test.dart';
import '../../built_value_generator/lib/src/plugin/checker.dart';
import 'package:test/test.dart';

Future expectCorrection(String src, String expectedFixedSource) async {
  final checker = new Checker();
  final srcPrefix = 'library test_library; class Built {};';
  final totalSrc = '$srcPrefix$src';

  final element = await resolveSource(
      totalSrc, (resolver) => resolver.findLibraryByName('test_library'));

  final results = checker.check(element);

  // TODO: find shared code that does this.
  var fixedSrc = totalSrc;

  final edits = results.values
      .expand((correction) =>
          correction.change.edits.expand((edits) => edits.edits))
      .toList();
  edits.sort((left, right) {
    return right.offset.compareTo(left.offset);
  });

  for (final edit in edits) {
        fixedSrc = fixedSrc.replaceRange(
            edit.offset, edit.offset + edit.length, edit.replacement);
  }

  expect(fixedSrc, startsWith(srcPrefix));
  fixedSrc = fixedSrc.substring(srcPrefix.length);

  expect(fixedSrc, expectedFixedSource);
}

Future expectNoCorrection(String src) async {
  final checker = new Checker();
  final srcPrefix = 'library test_library; class Built {};';
  final totalSrc = '$srcPrefix$src';

  final element = await resolveSource(
      totalSrc, (resolver) => resolver.findLibraryByName('test_library'));

  expect(
      checker.check(element).values.expand((correction) =>
          correction.change.edits.expand((edits) => edits.edits)),
      isEmpty);
}
