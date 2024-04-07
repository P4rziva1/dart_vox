import 'dart:io';

import 'package:dart_vox/src/models/color.dart';
import 'package:dart_vox/src/models/color_palette.dart';
import 'package:dart_vox/src/models/model.dart';
import 'package:dart_vox/src/models/voxel.dart';

void main(List<String> args) {
  // serialize();
  parse('multi.vox');
}

void parse(String name) {
  File file = File(name);
  Model.fromBytes(file.readAsBytesSync());
}

void serialize() {
  Model model = Model(
    shapes: [
      Shape(size: Size(5, 5, 5), voxels: [
        Voxel(0, 0, 0, 1),
        Voxel(0, 0, 1, 2),
        Voxel(0, 0, 2, 3),
        Voxel(0, 0, 3, 4),
        Voxel(0, 0, 4, 5),
      ])
    ],
    colorPalette: ColorPalette.fromColors(
      [
        VoxColor(255, 0, 0, 255),
        VoxColor(0, 255, 0, 255),
        VoxColor(0, 0, 255, 255),
        VoxColor(123, 123, 50, 255),
        VoxColor(0, 0, 0, 255),
      ],
    ).colors,
  );
  serializeModel('example', model);
}

void serializeModel(String fileName, Model model) {
  File file = File('$fileName.vox');
  file.writeAsBytesSync(model.toBytes());
}

void exportObj(String fileName, Model model) {
  File file = File('$fileName.obj');
  file.writeAsStringSync(model.toObj());
}
