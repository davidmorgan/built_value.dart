import 'dart:io';

File file;

void log(String string) {
  if (file == null) {
    file = new File('/tmp/plugin-log')..writeAsStringSync('');
  }

  file.writeAsStringSync(string, mode: FileMode.APPEND);
  file.writeAsStringSync('\n', mode: FileMode.APPEND);
}
