import 'dart:io';
import 'dart:typed_data';

import 'package:dart_vox/dart_vox.dart';

void main() {
  File file = File('./test/data/3x3x3.vox');
  Uint8List bytes = file.readAsBytesSync();
  Model model = Model.fromBytes(bytes);
  File obj = File('./example/test.obj');
  obj.writeAsStringSync(model.toObj());
}
