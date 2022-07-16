import 'dart:io';
import 'dart:typed_data';

import 'package:dart_vox/dart_vox.dart';
import 'package:dart_vox/src/models/model.dart';
import 'package:test/test.dart';

void main() {
  group('base tests', () {
    setUp(() {});

    test('parse simple .vox file', () {
      File file = File('./test/data/3x3x3.vox');
      Uint8List bytes = file.readAsBytesSync();
      Model model = Model.fromBytes(bytes);
      expect(model.voxels.length, 20);
      expect(model.toBytes(), bytes);
    });
  });
}
