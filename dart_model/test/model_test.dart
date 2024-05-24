import 'package:dart_model/model.dart';
import 'package:test/test.dart';

void main() {
  group(Model, () {
    final model = Model.fromJson({
      'package:end_to_end_test/values.dart': {
        'SimpleValue': {
          'properties': ['abstract', 'class   ', 'final'],
          'implements': [
            {
              'name': 'Built',
              'parameters': [
                'package:end_to_end_test/values.dart#SimpleValue',
                'package:end_to_end_test/values.dart#SimpleValueBuilder',
              ]
            },
          ],
          'members': {
            'serializer': {
              'properties': ['static', 'getter'],
              'returnType': {
                'name': 'Serializer',
                'parameters': [
                  'package:end_to_end_test/values.dart#SimpleValue',
                ]
              }
            },
            'anInt': {
              'properties': ['abstract', 'getter'],
              'returnType': 'dart:core#int',
            },
            'aString': {
              'properties': ['abstract', 'getter'],
              'returnType': 'dart:core#String?',
            },
          },
        }
      }
    });

    test('works as described', () {
      expect(model.uris, ['package:end_to_end_test/values.dart']);

      final library = model.library('package:end_to_end_test/values.dart')!;
      expect(library.names, ['SimpleValue']);
    });
  });
}
