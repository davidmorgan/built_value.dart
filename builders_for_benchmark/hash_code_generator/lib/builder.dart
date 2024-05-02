import 'package:analyzer/dart/element/element.dart';
import 'package:annotations_for_benchmark/annotations.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder builder(BuilderOptions _) => LibraryBuilder(HashCodeGenerator(),
    formatOutput: (code) => code, generatedExtension: '.hash_code.dart');

class HashCodeGenerator extends GeneratorForAnnotation {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    return 'augment library "${library.element.source.uri}";\n\n' +
        await super.generate(library, buildStep);
  }

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final result = StringBuffer();
    final clazz = element as ClassElement;
    final fields = element.fields;

    result.writeln('augment class ${clazz.name} {');
    result.writeln([
      'get hashCode {',
      'hashType<T>() => T.hashCode;',
      'return hashType<',
      clazz.name,
      '>()',
      for (final field in fields) ...[
        ' ^ ',
        field.name,
        '.hashCode',
      ],
      ";}",
    ].join(''));
    result.writeln('}');

    return result.toString();
  }

  @override
  TypeChecker get typeChecker => TypeChecker.fromRuntime(HashCode);
}
