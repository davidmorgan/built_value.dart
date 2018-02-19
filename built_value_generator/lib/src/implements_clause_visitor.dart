// Copyright (c) 2016, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:built_value_generator/src/fixes.dart';

/// Extracts the "implements" clause of a class; or, if there isn't one, works
/// out where it should go.
class ImplementsClauseVisitor extends RecursiveAstVisitor {
  SourceSnippet _placeForImplementsClause;
  SourceSnippet _implementsClause;

  @override
  void visitClassDeclaration(ClassDeclaration classDeclaration) {
    _placeForImplementsClause = new SourceSnippet((b) => b
      ..offset = classDeclaration.leftBracket.offset - 1
      ..source = '');
    super.visitClassDeclaration(classDeclaration);
  }

  @override
  void visitImplementsClause(ImplementsClause implementsClause) {
    _implementsClause = new SourceSnippet.node(implementsClause);
  }

  SourceSnippet get result => _implementsClause ?? _placeForImplementsClause;
}
