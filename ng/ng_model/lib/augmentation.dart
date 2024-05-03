import 'source.dart';

class Augmentation {
  final String uri;
  final String? name;
  final String code;
  final String description;

  Augmentation.classMember(Identifier identifier, this.code)
      : uri = identifier.uri,
        name = identifier.name,
        description = 'Augmentation(add member to $identifier: $code)';
  Augmentation.code(this.uri, this.code)
      : name = null,
        description = 'Augmentation(add code to $uri: $code)';

  bool operator ==(Object other) =>
      other is Augmentation &&
      uri == other.uri &&
      name == other.name &&
      code == other.code;

  String toString() => description;

  static String mergeToSource(Iterable<Augmentation> augmentations) {
    final output = StringBuffer();

    for (final identifier in augmentations
        .where((a) => a.name != null)
        .map((a) => Identifier(a.uri, a.name!, null))
        .toSet()) {
      final identifierAugmentations = augmentations
          .where((a) => Identifier(a.uri, a.name!, null) == identifier)
          .toList();

      output.writeln('augment class ${identifier.name} {');
      for (final augmentation in identifierAugmentations) {
        output.writeln(augmentation.code);
      }
      output.writeln('}');
    }

    for (final augmentation
        in augmentations.where((a) => a.name == null).toSet()) {
      output.writeln(augmentation.code);
    }

    return output.toString();
  }
}
