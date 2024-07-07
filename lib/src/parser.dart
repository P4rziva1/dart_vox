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
    offset += valueSize;
    print(chunkId);
    switch (chunkId) {
      case 'VOX ':
        offset += valueSize;
        break;
      case 'MAIN':
        offset += metaSize;
        break;
      case 'PACK':
        offset += metaSize + valueSize;
        break;
      case 'SIZE':
        offset += metaSize;
        sizeX = getInt(bytes, offset);
        offset += valueSize;
        sizeY = getInt(bytes, offset);
        offset += valueSize;
        sizeZ = getInt(bytes, offset);
        offset += valueSize;
        break;
      case 'XYZI':
        offset += metaSize;
        int numVoxels = getInt(bytes, offset);
        offset += valueSize;
        offset += valueSize * numVoxels;
        voxels =
            parseXYZI(bytes.sublist(offset, offset + numVoxels * valueSize));
        break;
      case 'RGBA':
        offset += metaSize;
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
      case 'nTRN':
        offset += metaSize;
        //INT32 node id
        int nodeId = getInt(bytes, offset);
        print('nodeId $nodeId');
        offset += valueSize;
        //DICT Attribute
        (Map, int) dict = getDict(bytes.sublist(offset));
        print('dict ${dict.$1}');
        print('offset ${dict.$2}');
        offset += dict.$2;
        //INT32 child node id
        int childNodeId = getInt(bytes, offset);
        print('childNodeId $childNodeId');
        offset += valueSize;
        //INT32 reserved id
        int reservedId = getInt(bytes, offset);
        print('reservedId $reservedId');
        offset += valueSize;
        //INT32 layer id
        int layerId = getInt(bytes, offset);
        print('layerId $layerId');
        offset += valueSize;
        //INT32 num of frames
        int frames = getInt(bytes, offset);
        print('frames $frames');
        offset += valueSize;
        //DICT frame stuff
        (Map, int) frameStuff = getDict(bytes.sublist(offset));
        print('frameStuff ${frameStuff.$1}');
        print('offset ${frameStuff.$2}');
        offset += frameStuff.$2;
        break;

      case 'nGRP':
        offset += metaSize;
        //INT32 node id
        int nodeId = getInt(bytes, offset);
        print('nodeId $nodeId');
        offset += valueSize;
        //DICT Attribute
        (Map, int) dict = getDict(bytes.sublist(offset));
        print('dict ${dict.$1}');
        print('offset ${dict.$2}');
        offset += dict.$2;
        //INT32 child node id
        int numChildrenNodes = getInt(bytes, offset);
        print('numChildren $numChildrenNodes');
        offset += valueSize;
        for (int i = 0; i < numChildrenNodes; i++) {
          int childId = getInt(bytes, offset);
          print('$i childId $childId');
          offset += valueSize;
        }
        break;

      case 'nSHP':
        offset += metaSize;
        //INT32 node id
        int nodeId = getInt(bytes, offset);
        print('nodeId $nodeId');
        offset += valueSize;
        //DICT Attribute
        (Map, int) dict = getDict(bytes.sublist(offset));
        print('dict ${dict.$1}');
        print('offset ${dict.$2}');
        offset += dict.$2;
        //INT32 child node id
        int numOfModels = getInt(bytes, offset);
        print('numOfModels $numOfModels');
        offset += valueSize;
        for (int i = 0; i < numOfModels; i++) {
          int modelId = getInt(bytes, offset);
          print('$i modelId $modelId');
          offset += valueSize;
        }
        break;

      default:
        print(chunkId);
        int chunkLength = getInt(bytes, offset);
        print('len $chunkLength');
        offset += metaSize;
        offset += chunkLength;
        break;
    }
  }
  return Model(shapes: [
    Shape(
      size: Size(sizeX, sizeY, sizeZ),
      voxels: voxels,
    ),
  ], colorPalette: colors);
}

int getInt(Uint8List bytes, offset) {
  ByteData data = bytes.sublist(offset, offset + 4).buffer.asByteData();
  return data.getUint32(0, Endian.little);
}
