// Copyright (c) 2018, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:built_value/built_value.dart';

part 'fixes.g.dart';

abstract class SourceSnippet
    implements Built<SourceSnippet, SourceSnippetBuilder> {
  int get offset;
  String get source;

  factory SourceSnippet([updates(SourceSnippetBuilder b)]) = _$SourceSnippet;
  factory SourceSnippet.node(AstNode node) =>
      new _$SourceSnippet._(offset: node.offset, source: node.toSource());
  SourceSnippet._();
}

abstract class GeneratorError
    implements Built<GeneratorError, GeneratorErrorBuilder> {
  String get message;

  int get offset;
  int get length;

  @nullable
  String get fix;

  factory GeneratorError([updates(GeneratorErrorBuilder b)]) = _$GeneratorError;
  GeneratorError._();
}
