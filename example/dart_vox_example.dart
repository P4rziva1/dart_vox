import 'dart:io';

import 'package:dart_vox/src/models/color.dart';
import 'package:dart_vox/src/models/color_palette.dart';
import 'package:dart_vox/src/models/model.dart';
import 'package:dart_vox/src/models/nodes.dart';
import 'package:dart_vox/src/models/voxel.dart';

void main(List<String> args) {
  serialize();
  // parse('multi.vox');
}

void parse(String name) {
  File file = File(name);
  Model.fromBytes(file.readAsBytesSync());
}

void serialize() {
  Model model = Model(
    shapes: [
      Shape(
        size: Size(5, 5, 5),
        voxels: [
          Voxel(0, 0, 0, 79),
          Voxel(0, 0, 1, 78),
          Voxel(0, 0, 2, 79),
          Voxel(0, 0, 3, 79),
          Voxel(0, 0, 4, 79),
        ],
        translation: Translation(-3, 0, 2),
      ),
      Shape(
        size: Size(5, 5, 5),
        translation: Translation(2, 0, 2),
        voxels: [
          Voxel(0, 0, 0, 1),
          Voxel(0, 0, 1, 2),
          Voxel(0, 0, 2, 3),
          Voxel(0, 0, 3, 4),
          Voxel(0, 0, 4, 5),
        ],
      ),
      Shape(
        size: Size(5, 5, 5),
        translation: Translation(2, 10, 2),
        voxels: [
          Voxel(0, 0, 0, 1),
          Voxel(0, 0, 1, 2),
          Voxel(2, 0, 2, 3),
          Voxel(3, 0, 3, 4),
          Voxel(1, 0, 4, 5),
        ],
      )
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
  serializeModel('example_multi', model);
}

void serializeModel(String fileName, Model model) {
  File file = File('$fileName.vox');
  file.writeAsBytesSync(model.toBytes());
}

void exportObj(String fileName, Model model) {
  File file = File('$fileName.obj');
  file.writeAsStringSync(model.toObj());
}
