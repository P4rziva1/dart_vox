import 'dart:typed_data';

import 'package:dart_vox/dart_vox.dart';
import 'package:dart_vox/src/models/nodes.dart';

//Create the bytes from bottom up so we know the size of the remaining ones when we need them
Uint8List smartSerialize(Model model) {
  List<int> bytes = [];
  if (model.colorPalette.isNotEmpty) {
    bytes.insertAll(0, createRGBAChunk(model.colorPalette));
  }
  List<Uint8List> sceneGraphChunks = [];
  List<TransformNode> transformNodes = [];
  List<ShapeNode> shapeNodes = [];
  int nextNodeId = 2;
  int nextModelId = 0;
  for (Shape shape in model.shapes) {
    if (shape.voxels.isEmpty) {
      throw 'voxels can not be empty';
    }
    bytes.addAll(createSizeChunk(shape.size));
    bytes.addAll(createXYZIChunk(shape.voxels));

    int transformNodeId = nextNodeId;
    nextNodeId++;
    int shapeNodeId = nextNodeId;
    nextNodeId++;
    TransformNode transformNode = TransformNode(
      id: transformNodeId,
      childId: shapeNodeId,
      translation: shape.translation,
    );
    transformNodes.add(transformNode);

    // Create a ShapeNode for each model
    ShapeNode shapeNode = ShapeNode(
      id: shapeNodeId,
      modelId: nextModelId++,
    );
    shapeNodes.add(shapeNode);

    sceneGraphChunks.add(serializeTransformNode(transformNode));
    sceneGraphChunks.add(serializeShapeNode(shapeNode));
  }
  // Create a single GroupNode that groups all shapes by their transform
  GroupNode groupNode = GroupNode(
    id: 1,
    childrenIds: transformNodes.map((node) => node.id).toList(),
  );
  sceneGraphChunks.insert(0, serializeGroupNode(groupNode));
  bytes.addAll(baseTransformNode());
  for (Uint8List chunk in sceneGraphChunks) {
    bytes.addAll(chunk.toList());
  }

  bytes.insertAll(0, createMainChunk(bytes.length));
  bytes.insertAll(0, createVoxChunk());
  return Uint8List.fromList(bytes);
}

Uint8List createMainChunk(int size) {
  BytesBuilder builder = BytesBuilder();
  builder.add(encodeString('MAIN'));
  builder.add(createChunkMetadata(0, size));
  return builder.toBytes();
}

Uint8List createPackChunk(int numModels) {
  BytesBuilder builder = BytesBuilder();
  builder.add(encodeString('PACK'));
  builder.add(createChunkMetadata(4, 0));
  builder.add(serializeValue(numModels));
  return builder.toBytes();
}

Uint8List createSizeChunk(Size size) {
  BytesBuilder builder = BytesBuilder();
  builder.add(encodeString('SIZE'));
  builder.add(createChunkMetadata(3 * 4, 0));
  builder.add(serializeValue(size.x));
  builder.add(serializeValue(size.y));
  builder.add(serializeValue(size.z));
  return builder.toBytes();
}

Uint8List createVoxChunk() {
  BytesBuilder builder = BytesBuilder();
  builder.add(encodeString('VOX '));
  builder.add(serializeValue(150));
  return builder.toBytes();
}

Uint8List createXYZIChunk(List<Voxel> voxels) {
  BytesBuilder chunkBuilder = BytesBuilder();
  chunkBuilder.add(encodeString('XYZI'));
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
  chunkBuilder.add(encodeString('RGBA'));
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
  builder.add(encodeString('nTRN'));
  builder.add(serializeValue(28));
  builder.add(serializeValue(0));
  builder.add(serializeValue(0));
  builder.add(serializeValue(0));
  builder.add(serializeValue(1));
  builder.add(serializeValue(-1));
  builder.add(serializeValue(0));
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
  content.add(encodeString('_t')); // key
  final Uint8List transform = createTransform(node.translation);
  content.add(serializeValue(transform.length));
  content.add(transform);

  BytesBuilder chunk = BytesBuilder();
  chunk.add(encodeString('nTRN'));
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
  }

  BytesBuilder chunk = BytesBuilder();
  chunk.add(encodeString('nGRP'));
  chunk.add(serializeValue(content.length)); // Placeholder for chunk size
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
  chunk.add(encodeString('nSHP'));
  chunk.add(serializeValue(content.length));
  chunk.add(serializeValue(0)); // chunk id
  chunk.add(content.takeBytes());
  return chunk.takeBytes();
}

Uint8List encodeString(String string) {
  return Uint8List.fromList(string.codeUnits);
}

Uint8List createTransform(Translation translation) {
  return Uint8List.fromList(
    '${translation.x} ${translation.y} ${translation.z}'.codeUnits,
  );
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

class ShapeKey {
  final int x, y, z;

  ShapeKey(this.x, this.y, this.z);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShapeKey &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          z == other.z;

  @override
  String toString() {
    return '$x-$y-$z';
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;
}

const int maxSize = 256;
Model modelFromVoxels(List<Voxel> voxels) {
  // Use a Map to group voxels by their shape keys
  Map<ShapeKey, List<Voxel>> shapes = {};

  for (Voxel voxel in voxels) {
    final int shapeX = voxel.x ~/ maxSize;
    final int shapeY = voxel.y ~/ maxSize;
    final int shapeZ = voxel.z ~/ maxSize;
    ShapeKey key = ShapeKey(shapeX, shapeY, shapeZ);

    // Calculate offset for the voxel within its shape
    final Voxel offsetVoxel = Voxel(
      voxel.x % maxSize,
      voxel.y % maxSize,
      voxel.z % maxSize,
      voxel.color,
    );

    if (!shapes.containsKey(key)) {
      shapes[key] = [];
    }
    shapes[key]!.add(offsetVoxel);
  }

  // Initialize the model with the correct color palette
  final Model model = Model(
    shapes: [],
    colorPalette: [
      VoxColor(255, 0, 0, 255),
      VoxColor(0, 255, 0, 255),
      VoxColor(0, 0, 255, 255),
    ],
  );

  shapes.forEach(
    (key, value) {
      // ShapeKey already contains x, y, z
      final int x = key.x;
      final int y = key.y;
      final int z = key.z;
      // TODO: reduce shape to required size
      // We use a fixed offset to make better use of the .vox general size limitations
      // TODO: make dynamic
      final Translation translation = Translation(
        -872 + x * maxSize,
        -872 + y * maxSize,
        128 + z * maxSize,
      );
      // Add shapes to the model
      model.shapes.add(
        Shape(
          size: Size(maxSize, maxSize,
              maxSize), // Size(shapeSize, shapeSize, shapeSize),
          voxels: value,
          translation: translation,
        ),
      );
    },
  );

  return model;
}
