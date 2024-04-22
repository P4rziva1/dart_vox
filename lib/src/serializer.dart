import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_vox/dart_vox.dart';
import 'package:dart_vox/src/constants.dart';
import 'package:dart_vox/src/models/model.dart';
import 'package:dart_vox/src/models/nodes.dart';
import 'package:dart_vox/src/models/voxel.dart';

import 'models/color.dart';

//Create the bytes from bottom up so we know the size of the remaining ones when we need them
Uint8List smartSerialize(Model model) {
  List<int> bytes = [];
  // if (model.colorPalette.isNotEmpty) {
  //   bytes.insertAll(0, createRGBAChunk(model.colorPalette));
  // }
  List<Uint8List> sceneGraphChunks = [];
  List<TransformNode> transformNodes = [];
  List<ShapeNode> shapeNodes = [];
  int nextNodeId = 2;
  int nextModelId = 0;
  for (Shape shape in model.shapes) {
    if (shape.voxels.isEmpty) {
      throw 'voxels can not be empty';
    }
      bytes.insertAll(0, createXYZIChunk(shape.voxels));
      bytes.insertAll(0, createSizeChunk(shape.size));
      // Create a TransformNode for each model with an example translation
      TransformNode transformNode = TransformNode(
        id: nextNodeId++,
        childId: nextNodeId,
        translation: shape.translation,
      );
      transformNodes.add(transformNode);

      // Create a ShapeNode for each model
      //FIXME: What is the modelId?
      ShapeNode shapeNode = ShapeNode(id: nextNodeId++, modelId: nextModelId++);
      shapeNodes.add(shapeNode);

      sceneGraphChunks.add(serializeTransformNode(transformNode));
    // transformNodes.forEach((node) {
    // });
      sceneGraphChunks.add(serializeShapeNode(shapeNode));
    // shapeNodes.forEach((node) {
    // });
  }
  // Create a single GroupNode that groups all shapes
  GroupNode groupNode = GroupNode(
      id: 1, childrenIds: transformNodes.map((node) => node.id).toList());
  sceneGraphChunks.insert(0, serializeGroupNode(groupNode));
  bytes.addAll(baseTransformNode());
  sceneGraphChunks.forEach((element) {
    bytes.addAll(element.toList());
  });

  // bytes.insertAll(0, createPackChunk(1));
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
  // builder.add(serializeValue(200));
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

Uint8List baseTransformNode() {
  BytesBuilder builder = BytesBuilder();
  builder.add(createChunkId('nTRN'));
  builder.add(serializeValue(28));
  builder.add(serializeValue(0));
  builder.add(serializeValue(0));
  builder.add(serializeValue(0));
  builder.add(serializeValue(1));
  builder.add(serializeValue(-1));
  builder.add(serializeValue(-1)); // whatever -1 was 0
  builder.add(serializeValue(1));
  builder.add(serializeValue(0));
  return builder.toBytes();
}

Uint8List serializeTransformNode(TransformNode node) {
  BytesBuilder content = BytesBuilder();

  content.add(serializeValue(node.id));
  content.add(serializeValue(0)); // empty dict
  content.add(serializeValue(node.childId)); //
  content.add(serializeValue(-1)); // Reserved ID (must be -1)
  content.add(serializeValue(0)); // Layer ID
  content.add(serializeValue(1)); // Number of frames

  // Frame
  content.add(serializeValue(1)); // Num Keys
  content.add(serializeValue(2)); // length of key
  content.add(createChunkId('_t')); // key
  final Uint8List transform = createTransform(node.translation);
  content.add(serializeValue(transform.length));
  content.add(transform);

  BytesBuilder chunk = BytesBuilder();
  chunk.add(createChunkId('nTRN'));
  chunk.add(serializeValue(content.length));
  chunk.add(serializeValue(0)); // Chunk Id
  chunk.add(content.takeBytes());
  return chunk.takeBytes();
}

Uint8List serializeGroupNode(GroupNode node) {
  BytesBuilder content = BytesBuilder();
  content.add(serializeValue(node.id));
  content
      .add(serializeValue(0)); // Dictionary size (attributes), currently empty

  content.add(serializeValue(node.childrenIds.length));
  for (int childId in node.childrenIds) {
    content.add(serializeValue(childId));
    print('childID -> $childId');
  }

  BytesBuilder chunk = BytesBuilder();
  chunk.add(createChunkId('nGRP'));
  chunk.add(serializeValue(content.length)); // Placeholder for chunk size
  // FIXME: Was node id -> 1
  chunk.add(serializeValue(0));
  chunk.add(content.takeBytes());
  return chunk.takeBytes();
}

Uint8List serializeShapeNode(ShapeNode node) {
  BytesBuilder content = BytesBuilder();
  content.add(serializeValue(node.id));
  content.add(serializeValue(0)); // node attributes -> empty dict
  content.add(serializeValue(1)); // number of models
  // For models
  content.add(serializeValue(node.modelId)); // model id
  content.add(serializeValue(0)); // dict model attributes

  BytesBuilder chunk = BytesBuilder();
  chunk.add(createChunkId('nSHP'));
  chunk.add(serializeValue(content.length));
  chunk.add(serializeValue(0)); // chunk id
  chunk.add(content.takeBytes());
  return chunk.takeBytes();
}

Uint8List createChunkId(String string) {
  return Uint8List.fromList(string.codeUnits);
}

Uint8List createTransform(Translation translation) {
  return Uint8List.fromList([
    ...translation.x.toString().codeUnits,
    0x20,
    ...translation.y.toString().codeUnits,
    0x20,
    ...translation.z.toString().codeUnits
  ]);
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
