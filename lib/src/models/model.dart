import 'dart:typed_data';

import 'package:dart_vox/src/models/color.dart';
import 'package:dart_vox/src/models/voxel.dart';
import 'package:dart_vox/src/parser.dart';
import 'package:dart_vox/src/serializer.dart';
import 'package:vector_math/vector_math.dart';

class Model {
  int sizeX;
  int sizeY;
  int sizeZ;
  final List<Voxel> voxels;
  final List<VoxColor> colorPalette;

  Model(this.voxels, this.sizeX, this.sizeY, this.sizeZ, this.colorPalette);

  factory Model.fromBytes(Uint8List bytes) {
    return parseBytes(bytes);
  }

  Uint8List toBytes() {
    return smartSerialize(this);
  }
}
