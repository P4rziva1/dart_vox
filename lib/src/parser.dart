import 'dart:typed_data';

import 'package:dart_vox/src/constants.dart';
import 'package:dart_vox/src/models/color.dart';
import 'package:dart_vox/src/models/model.dart';
import 'package:dart_vox/src/tools.dart';

import 'models/voxel.dart';

// Byte reader implementation: https://github.com/spnda/dart_minecraft/blob/main/lib/src/utilities/readers/_byte_reader.dart
Model parseBytes(Uint8List bytes) {
  int sizeX = 0;
  int sizeY = 0;
  int sizeZ = 0;
  List<Voxel> voxels = [];
  List<VoxColor> colors = [];

  int offset = 0;
  //TODO: Get content size then pass sublist to dedocated function
  while (offset < bytes.length) {
    String chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    offset += VALUE_SIZE;
    switch (chunkId) {
      case 'VOX ':
        offset += VALUE_SIZE;
        break;
      case 'MAIN':
        offset += META_SIZE;
        break;
      case 'PACK':
        offset += META_SIZE + VALUE_SIZE;
        break;
      case 'SIZE':
        offset += META_SIZE;
        sizeX = getInt(bytes, offset);
        offset += VALUE_SIZE;
        sizeY = getInt(bytes, offset);
        offset += VALUE_SIZE;
        sizeZ = getInt(bytes, offset);
        offset += VALUE_SIZE;
        break;
      case 'XYZI':
        offset += META_SIZE;
        int numVoxels = getInt(bytes, offset);
        offset += VALUE_SIZE;
        voxels =
            parseXYZI(bytes.sublist(offset, offset + numVoxels * VALUE_SIZE));
        break;
      case 'RGBA':
        offset += META_SIZE;
        for (int i = 0; i <= 255; i++) {
          int r = bytes[offset];
          offset++;
          int g = bytes[offset];
          offset++;
          int b = bytes[offset];
          offset++;
          int a = bytes[offset];
          offset++;
          colors.add(VoxColor(r, g, b, a));
        }
        break;

      default:
        offset += META_SIZE;
        break;
    }
  }
  return Model(voxels, sizeX, sizeY, sizeZ, colors);
}

int getInt(Uint8List bytes, offset) {
  ByteData data = bytes.sublist(offset, offset + 4).buffer.asByteData();
  return data.getUint32(0, Endian.little);
}
// int readInt(Iterable<int> bytes) {
//   ByteData
// }
