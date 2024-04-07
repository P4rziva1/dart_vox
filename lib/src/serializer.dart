import 'dart:typed_data';

import 'package:dart_vox/src/constants.dart';
import 'package:dart_vox/src/models/model.dart';
import 'package:dart_vox/src/models/voxel.dart';

import 'models/color.dart';

//Create the bytes from bottom up so we know the size of the remaining ones when we need them
Uint8List smartSerialize(Model model) {
  List<int> bytes = [];
  if (model.colorPalette.isNotEmpty) {
    bytes.insertAll(0, createRGBAChunk(model.colorPalette));
  }
  for (Shape shape in model.shapes) {
    if (shape.voxels.isNotEmpty) {
      bytes.insertAll(0, createXYZIChunk(shape.voxels));
      bytes.insertAll(0, createSizeChunk(shape.size));
    }
  }

  bytes.insertAll(0, createPackChunk(1));
  print(bytes.length);
  bytes.insertAll(0, createMainChunk(bytes.length));
  bytes.insertAll(0, createVoxChunk());
  return Uint8List.fromList(bytes);
}

Uint8List createMainChunk(int size) {
  BytesBuilder builder = BytesBuilder();
  builder.add(createChunkId('MAIN'));
  builder.add(createChunkMetadata(0, size));
  return builder.toBytes();
}

Uint8List createPackChunk(int numModels) {
  BytesBuilder builder = BytesBuilder();
  builder.add(createChunkId('PACK'));
  builder.add(createChunkMetadata(4, 0));
  builder.add(serializeValue(numModels));
  return builder.toBytes();
}

Uint8List createSizeChunk(Size size) {
  BytesBuilder builder = BytesBuilder();
  builder.add(createChunkId('SIZE'));
  builder.add(createChunkMetadata(3 * 4, 0));
  builder.add(serializeValue(size.x));
  builder.add(serializeValue(size.y));
  builder.add(serializeValue(size.z));
  return builder.toBytes();
}

Uint8List createVoxChunk() {
  BytesBuilder builder = BytesBuilder();
  builder.add(createChunkId('VOX '));
  builder.add(serializeValue(150));
  return builder.toBytes();
}

Uint8List createXYZIChunk(List<Voxel> voxels) {
  BytesBuilder chunkBuilder = BytesBuilder();
  chunkBuilder.add(createChunkId('XYZI'));
  chunkBuilder.add(createChunkMetadata(voxels.length * 4 + 4, 0));
  chunkBuilder.add(serializeValue(voxels.length));
  BytesBuilder voxelBuilder = BytesBuilder();
  for (Voxel vox in voxels) {
    voxelBuilder.add([
      vox.x,
      vox.y,
      vox.z,
      vox.color,
    ]);
  }
  chunkBuilder.add(voxelBuilder.toBytes());
  print('voxels length: ${voxels.length}');
  print('bytes length: ${chunkBuilder.toBytes().length}');
  return chunkBuilder.toBytes();
}

Uint8List createChunkMetadata(int chunk, int children) {
  ByteData data = Uint8List(8).buffer.asByteData();
  data.setUint32(0, chunk, Endian.little);
  data.setUint32(4, children, Endian.little);
  return data.buffer.asUint8List();
}

Uint8List createRGBAChunk(List<VoxColor> colors) {
  BytesBuilder chunkBuilder = BytesBuilder();
  chunkBuilder.add(createChunkId('RGBA'));
  chunkBuilder.add(createChunkMetadata(colors.length * 4, 0));
  BytesBuilder colorBuilder = BytesBuilder();
  for (VoxColor color in colors) {
    colorBuilder.add([
      color.r,
      color.g,
      color.b,
      color.a,
    ]);
  }
  chunkBuilder.add(colorBuilder.toBytes());
  return chunkBuilder.toBytes();
}

Uint8List createChunkId(String string) {
  return Uint8List.fromList(string.codeUnits);
}

Uint8List serializeValue(int value) {
  Uint8List bytes = Uint8List(4);
  bytes.buffer.asByteData().setUint32(0, value, Endian.little);
  return bytes;
}

Size getShapeSize(List<Voxel> voxels) {
  int maxX = 0;
  int maxY = 0;
  int maxZ = 0;
  for (Voxel vox in voxels) {
    if (vox.x > maxX) {
      maxX = vox.x;
    }
    if (vox.y > maxY) {
      maxY = vox.y;
    }
    if (vox.z > maxZ) {
      maxZ = vox.z;
    }
  }
  maxX++;
  maxY++;
  maxZ++;
  return Size(
    maxX,
    maxY,
    maxZ,
  );
}

Uint8List createShape(List<Voxel> voxel) {}
