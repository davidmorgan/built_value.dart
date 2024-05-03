import 'package:annotations_for_benchmark/annotations.dart';

import augment 'scratch.ng.dart';

@Equals()
@HashCode()
abstract class Baz {
  abstract int x;
  abstract int y;
  abstract int z;
}

@Equals()
@HashCode()
@ToString()
abstract class Bop {
  abstract int x;
  abstract int y;
  abstract int z;
  abstract int p;
  abstract int q;
  abstract int r;
  abstract int s;
  abstract int o;
}


