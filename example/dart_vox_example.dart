import 'dart:io';

import 'package:dart_vox/dart_vox.dart';
import 'package:dart_vox/src/models/nodes.dart';

void main(List<String> args) {
  fromVoxelList();
  // parse('multi.vox');
}

void parse(String name) {
  File file = File(name);
  Model.fromBytes(file.readAsBytesSync());
}

void fromShapes() {
  Model model = Model(
    shapes: [
      Shape(
        size: Size(256, 256, 256),
        voxels: [
          Voxel(0, 0, 0, 1),
        ],
        translation: Translation(0, 0, 0),
      ),
      Shape(
        size: Size(256, 256, 256),
        voxels: [
          Voxel(0, 0, 0, 2),
        ],
        translation: Translation(256, 0, 0),
      ),
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

  serializeModel('shapes', model);
}

void fromVoxelList() {
  Model model = modelFromVoxels(
    [
      ...createWall(
        start: Voxel(50, 50, 0, 0),
        end: Voxel(400, 50, 0, 0),
        height: 5,
        thickness: 1,
        color: 1,
      ),
      ...createWall(
        start: Voxel(400, 50, 0, 0),
        end: Voxel(200, 400, 0, 0),
        height: 5,
        thickness: 1,
        color: 1,
      ),
    ],
  );

  serializeModel('voxelList', model);
}

void serializeModel(String fileName, Model model) {
  File file = File('$fileName.vox');
  file.writeAsBytesSync(model.toBytes());
}

void exportObj(String fileName, Model model) {
  File file = File('$fileName.obj');
  file.writeAsStringSync(model.toObj());
}
