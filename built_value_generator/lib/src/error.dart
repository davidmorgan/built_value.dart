// Copyright (c) 2018, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:built_value/built_value.dart';

part 'error.g.dart';

abstract class GeneratorError implements Built<GeneratorError, GeneratorErrorBuilder> {
  String get message;

  int get fixAt;
  int get fixLength;
  String get fix;

  factory GeneratorError([updates(GeneratorErrorBuilder b)]) = _$GeneratorError;
  GeneratorError._();
}
