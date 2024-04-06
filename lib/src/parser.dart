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
    print(chunkId);
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
        offset += VALUE_SIZE * numVoxels;
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
      case 'nTRN':
        offset += META_SIZE;
        //INT32 node id
        int nodeId = getInt(bytes, offset);
        print('nodeId $nodeId');
        offset += VALUE_SIZE;
        //DICT Attribute
        (Map, int) dict = getDict(bytes.sublist(offset));
        print('dict ${dict.$1}');
        print('offset ${dict.$2}');
        offset += dict.$2;
        //INT32 child node id
        int childNodeId = getInt(bytes, offset);
        print('childNodeId $childNodeId');
        offset += VALUE_SIZE;
        //INT32 reserved id
        int reservedId = getInt(bytes, offset);
        print('reservedId $reservedId');
        offset += VALUE_SIZE;
        //INT32 layer id
        int layerId = getInt(bytes, offset);
        print('layerId $layerId');
        offset += VALUE_SIZE;
        //INT32 num of frames
        int frames = getInt(bytes, offset);
        print('frames $frames');
        offset += VALUE_SIZE;
        //DICT frame stuff
        (Map, int) frameStuff = getDict(bytes.sublist(offset));
        print('frameStuff ${frameStuff.$1}');
        print('offset ${frameStuff.$2}');
        offset += frameStuff.$2;
        break;

      case 'nGRP':
        offset += META_SIZE;
        //INT32 node id
        int nodeId = getInt(bytes, offset);
        print('nodeId $nodeId');
        offset += VALUE_SIZE;
        //DICT Attribute
        (Map, int) dict = getDict(bytes.sublist(offset));
        print('dict ${dict.$1}');
        print('offset ${dict.$2}');
        offset += dict.$2;
        //INT32 child node id
        int numChildrenNodes = getInt(bytes, offset);
        print('numChildren $numChildrenNodes');
        offset += VALUE_SIZE;
        for (int i = 0; i < numChildrenNodes; i++) {
          int childId = getInt(bytes, offset);
          print('$i childId $childId');
          offset += VALUE_SIZE;
        }
        break;

      case 'nSHP':
        offset += META_SIZE;
        //INT32 node id
        int nodeId = getInt(bytes, offset);
        print('nodeId $nodeId');
        offset += VALUE_SIZE;
        //DICT Attribute
        (Map, int) dict = getDict(bytes.sublist(offset));
        print('dict ${dict.$1}');
        print('offset ${dict.$2}');
        offset += dict.$2;
        //INT32 child node id
        int numOfModels = getInt(bytes, offset);
        print('numOfModels $numOfModels');
        offset += VALUE_SIZE;
        for (int i = 0; i < numOfModels; i++) {
          int modelId = getInt(bytes, offset);
          print('$i modelId $modelId');
          offset += VALUE_SIZE;
        }
        break;

      default:
        print(chunkId);
        int chunkLength = getInt(bytes, offset);
        print('len $chunkLength');
        offset += META_SIZE;
        offset += chunkLength;
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
