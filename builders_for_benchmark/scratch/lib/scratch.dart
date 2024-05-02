import 'package:annotations_for_benchmark/annotations.dart';

import augment 'scratch.equals.dart';
import augment 'scratch.hash_code.dart';
import augment 'scratch.to_string.dart';

@Equals()
@HashCode()
@ToString()
abstract class Foo {
  abstract int a;
  abstract int b;
  abstract int c;
  abstract int d;
  abstract int e;
  abstract int f;
  abstract int g;
  abstract int i;
}


@Equals()
@HashCode()
@ToString()
abstract class Bar {
  abstract int a;
  abstract int b;
  abstract int d;
  abstract int e;
  abstract int f;
}
