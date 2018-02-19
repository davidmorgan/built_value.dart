// Copyright (c) 2016, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:built_value_generator/src/fixes.dart';

/// Extracts the type parameters used for the `Built` interface.
class BuiltParametersVisitor extends RecursiveAstVisitor {
  SourceSnippet result;

  @override
  void visitImplementsClause(ImplementsClause implementsClause) {
    for (final interface in implementsClause.interfaces) {
      final extractedParameters = _extractParameters('Built<', interface.toString());

      if (extractedParameters != null) {
        result = new SourceSnippet((b) => b
          ..offset = interface.offset
          ..source = extractedParameters);
        break;
      }
    }
  }

  /// If [[code]] starts with [[prefix]] then strips it off, strips off the
  /// last character, and returns it.
  ///
  /// Otherwise returns null.
  String _extractParameters(String prefix, String code) {
    if (code.startsWith(prefix)) {
      return code.substring(prefix.length, code.length - 1);
    } else {
      return null;
    }
  }
}
