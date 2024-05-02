import 'dart:math';

final _random = Random.secure();
int get largeRandom =>
    _random.nextInt(0xFFFFFFFF) + (_random.nextInt(0x7FFFFFFF) << 32);
