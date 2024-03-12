// Copyright (c) 2016, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/src/dart/analysis/experiments.dart';
import 'package:built_collection/built_collection.dart';

var printing = false;

/// Tools for [LibraryElement]s.
class LibraryElements {
  static BuiltList<ClassElement> getClassElements(
      LibraryElement libraryElement) {
    var result = _GetClassesVisitor();
    libraryElement.visitChildren(result);
    for (final augmentation in libraryElement.augmentationImports) {
      print(
          '*** visiting augmentation ${(augmentation.uri as dynamic).source}');
      print(augmentation.children);
      printing = true;
      augmentation.importedAugmentation!.visitChildren(result);
      printing = false;
    }
    return BuiltList<ClassElement>(result.classElements);
  }

  static bool areClassMixinsEnabled(LibraryElement element) =>
      ExperimentStatus.knownFeatures.containsKey('class-modifiers') &&
      element.featureSet
          .isEnabled(ExperimentStatus.knownFeatures['class-modifiers']!);
}

/// Visitor that gets all [ClassElement]s.
class _GetClassesVisitor extends SimpleElementVisitor {
  final List<ClassElement> classElements = [];

  @override
  void visitClassElement(ClassElement element) {
    if (printing) print('Found class: ${element.displayName}');
    classElements.add(element);
  }

  @override
  void visitCompilationUnitElement(CompilationUnitElement element) {
    element.visitChildren(this);
  }
}
