import 'dart:io';

var file = null;

void log(String string) {
  if (file == null) {
    file = new File('/tmp/plugin-log')..writeAsStringSync('');
  }

  file.writeAsStringSync(string, mode: FileMode.APPEND);
  file.writeAsStringSync('\n', mode: FileMode.APPEND);
}
