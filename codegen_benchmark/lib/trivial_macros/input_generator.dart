import 'dart:io';

import 'package:codegen_benchmark/random.dart';
import 'package:codegen_benchmark/workspace.dart';

enum Strategy {
  manual,
  codegen,
  macro,
  incremental;

  String annotation(String name) {
    switch (this) {
      case Strategy.manual:
        return '';
      case Strategy.codegen:
        return '@c.$name()';
      case Strategy.macro:
        return '@m.$name()';
      case Strategy.incremental:
        return '@$name()';
    }
  }
}

class Strategies {
  final Strategy equalsStrategy;
  final Strategy hashCodeStrategy;
  final Strategy toStringStrategy;

  Strategies(
      {required this.equalsStrategy,
      required this.hashCodeStrategy,
      required this.toStringStrategy});

  factory Strategies.withNumberOfMacros(int number) {
    if (number < 0 || number > 3) {
      throw ArgumentError('Invalid number of macros: $number');
    }
    return Strategies(
      equalsStrategy: number >= 1 ? Strategy.macro : Strategy.manual,
      hashCodeStrategy: number >= 2 ? Strategy.macro : Strategy.manual,
      toStringStrategy: number >= 3 ? Strategy.macro : Strategy.manual,
    );
  }

  bool get anyMacroStrategy =>
      equalsStrategy == Strategy.macro ||
      hashCodeStrategy == Strategy.macro ||
      toStringStrategy == Strategy.macro;

  bool get anyCodegenStrategy =>
      equalsStrategy == Strategy.codegen ||
      hashCodeStrategy == Strategy.codegen ||
      toStringStrategy == Strategy.codegen;

  bool get anyIncrementalStrategy =>
      equalsStrategy == Strategy.incremental ||
      hashCodeStrategy == Strategy.incremental ||
      toStringStrategy == Strategy.incremental;

  String get equalsAnnotation => equalsStrategy.annotation('Equals');
  String get hashCodeAnnotation => hashCodeStrategy.annotation('HashCode');
  String get toStringAnnotation => toStringStrategy.annotation('ToString');
}

class TrivialMacrosInputGenerator {
  final int fieldsPerClass;
  final int classesPerLibrary;
  final int librariesPerCycle;
  final Strategies strategies;

  TrivialMacrosInputGenerator(
      {required this.fieldsPerClass,
      required this.classesPerLibrary,
      required this.librariesPerCycle,
      required this.strategies});

  void generate(Workspace workspace) {
    if (strategies.anyMacroStrategy) {
      workspace.write('lib/macros.dart',
          source: File('lib/trivial_macros/macros.dart').readAsStringSync());
    }

    if (strategies.anyCodegenStrategy || strategies.anyIncrementalStrategy) {
      workspace.addPackage(
          name: 'annotations_for_benchmark',
          from: '../builders_for_benchmark/annotations_for_benchmark');
    }
    if (strategies.equalsStrategy == Strategy.codegen) {
      workspace.addPackage(
          name: 'equals_generator',
          from: '../builders_for_benchmark/equals_generator');
    }
    if (strategies.hashCodeStrategy == Strategy.codegen) {
      workspace.addPackage(
          name: 'hash_code_generator',
          from: '../builders_for_benchmark/hash_code_generator');
    }
    if (strategies.toStringStrategy == Strategy.codegen) {
      workspace.addPackage(
          name: 'to_string_generator',
          from: '../builders_for_benchmark/to_string_generator');
    }

    for (var i = 0; i != librariesPerCycle; ++i) {
      workspace.write('lib/a$i.dart', source: _generateLibrary(i));
    }
  }

  String _generateLibrary(int index,
      {bool topLevelCacheBuster = false, bool fieldCacheBuster = false}) {
    final buffer = StringBuffer();

    if (strategies.anyMacroStrategy) {
      buffer.writeln("import 'macros.dart' as m;");
    }

    if (strategies.anyCodegenStrategy) {
      buffer.writeln(
          "import 'package:annotations_for_benchmark/annotations.dart' as c;");
    }
    if (strategies.anyIncrementalStrategy) {
      buffer.writeln(
          "import 'package:annotations_for_benchmark/annotations.dart';");
    }

    if (strategies.equalsStrategy == Strategy.codegen) {
      buffer.writeln("import augment 'a$index.equals.dart';");
    }
    if (strategies.hashCodeStrategy == Strategy.codegen) {
      buffer.writeln("import augment 'a$index.hash_code.dart';");
    }
    if (strategies.toStringStrategy == Strategy.codegen) {
      buffer.writeln("import augment 'a$index.to_string.dart';");
    }
    if (strategies.anyIncrementalStrategy) {
      buffer.writeln("import augment 'a$index.ng.dart';");
    }

    if (librariesPerCycle != 1) {
      final nextLibrary = (index + 1) % librariesPerCycle;
      buffer.writeln('import "a$nextLibrary.dart" as next_in_cycle;');
      buffer.writeln('next_in_cycle.A0? referenceOther;');
    }

    if (topLevelCacheBuster) {
      buffer.writeln('int? cacheBuster$largeRandom;');
    }

    for (var j = 0; j != classesPerLibrary; ++j) {
      buffer.write(_generateClass(j, fieldCacheBuster: fieldCacheBuster));
    }

    return buffer.toString();
  }

  String _generateClass(int index, {required bool fieldCacheBuster}) {
    final className = 'A$index';
    String fieldName(int index) => 'a$index';

    final result = StringBuffer('''
${strategies.equalsAnnotation}
${strategies.hashCodeAnnotation}
${strategies.toStringAnnotation}
''');

    result.writeln('abstract class $className {');
    if (fieldCacheBuster) {
      result.writeln('abstract int b$largeRandom;');
    }
    for (var i = 0; i != fieldsPerClass; ++i) {
      result.writeln('abstract int ${fieldName(i)};');
    }

    if (strategies.equalsStrategy == Strategy.manual) {
      result.writeln([
        'operator==(other) => other is ',
        className,
        for (var i = 0; i != fieldsPerClass; ++i) ...[
          '&&',
          fieldName(i),
          ' == other.',
          fieldName(i),
        ],
        ";",
      ].join(''));
    }

    if (strategies.hashCodeStrategy == Strategy.manual) {
      result.writeln([
        'get hashCode {',
        'hashType<T>() => T.hashCode;',
        'return hashType<',
        className,
        '>()',
        for (var i = 0; i != fieldsPerClass; ++i) ...[
          ' ^ ',
          fieldName(i),
          '.hashCode',
        ],
        ";}",
      ].join(''));
    }

    if (strategies.toStringStrategy == Strategy.manual) {
      result.writeln([
        "toString() => '\${",
        className,
        '}(',
        for (var i = 0; i != fieldsPerClass; ++i) ...[
          fieldName(i),
          ': \$',
          fieldName(i),
          if (i != fieldsPerClass - 1) ', ',
        ],
        ")';",
      ].join(''));
    }
    result.writeln('}');
    return result.toString();
  }

  void changeIrrelevantInput(Workspace workspace) {
    workspace.write('lib/a0.dart',
        source: _generateLibrary(0, topLevelCacheBuster: true));
  }

  void changeRevelantInput(Workspace workspace) {
    workspace.write('lib/a0.dart',
        source: _generateLibrary(0, fieldCacheBuster: true));
  }
}
