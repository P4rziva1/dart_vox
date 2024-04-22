import 'dart:typed_data';

import 'package:dart_vox/src/models/color.dart';
import 'package:dart_vox/src/models/nodes.dart';
import 'package:dart_vox/src/models/voxel.dart';
import 'package:dart_vox/src/parser.dart';
import 'package:dart_vox/src/serializer.dart';

enum UpAxis { Y_UP, Z_UP }

class Size {
  int x;
  int y;
  int z;
  Size(this.x, this.y, this.z);
}

class Shape {
  final Size size;
  final List<Voxel> voxels;
  final Translation translation;

  Shape({
    required this.size,
    required this.voxels,
    this.translation = const Translation(0, 0, 0),
  });
}

class Model {
  final List<Shape> shapes;
  final List<VoxColor> colorPalette;

  Model({required this.shapes, required this.colorPalette});

  factory Model.fromBytes(Uint8List bytes) {
    return parseBytes(bytes);
  }

  Uint8List toBytes() {
    return smartSerialize(this);
  }

  String toObj() {
    return convertVoxelsToObj(convertModelTo3DList());
  }

  //Limited to one shape
  List<List<List<bool>>> convertModelTo3DList() {
    // Initialize a 3D list with all values set to false
    if (shapes.isEmpty) {
      throw 'shapes must not be empty';
    }
    final Shape shape = this.shapes.first;

    final List<List<List<bool>>> voxels3D = List.generate(
      shape.size.x,
      (x) => List.generate(
        shape.size.y,
        (y) => List.generate(
          shape.size.z,
          (z) => false,
        ),
      ),
    );

    // Iterate through the voxels in the model and set the corresponding positions in the 3D list to true
    for (Voxel voxel in shape.voxels) {
      voxels3D[voxel.x][voxel.y][voxel.z] = true;
    }

    return voxels3D;
  }

  Map<String, int> uniqueVertices = {};
  List<String> vertexList = [];
  int currentVertexIndex = 1;
  String convertVoxelsToObj(List<List<List<bool>>> voxels) {
    var objBuilder = StringBuffer();

    for (var x = 0; x < voxels.length; x++) {
      for (var y = 0; y < voxels[x].length; y++) {
        for (var z = 0; z < voxels[x][y].length; z++) {
          if (voxels[x][y][z]) {
            // Check each face
            if (x == 0 || !voxels[x - 1][y][z]) {
              // Left face
              objBuilder.write(createFace(x, y, z, 'left'));
            }
            if (x == voxels.length - 1 || !voxels[x + 1][y][z]) {
              // Right face
              objBuilder.write(createFace(x, y, z, 'right'));
            }
            if (y == 0 || !voxels[x][y - 1][z]) {
              // Bottom face
              objBuilder.write(createFace(x, y, z, 'bottom'));
            }
            if (y == voxels[x].length - 1 || !voxels[x][y + 1][z]) {
              // Top face
              objBuilder.write(createFace(x, y, z, 'top'));
            }
            if (z == 0 || !voxels[x][y][z - 1]) {
              // Front face
              objBuilder.write(createFace(x, y, z, 'front'));
            }
            if (z == voxels[x][y].length - 1 || !voxels[x][y][z + 1]) {
              // Back face
              objBuilder.write(createFace(x, y, z, 'back'));
            }
          }
        }
      }
    }

    return '${vertexList.join('\n')}\n$objBuilder';
  }

  String createFace(int x, int y, int z, String face,
      [UpAxis upAxis = UpAxis.Y_UP]) {
    var vertices = <String>[];
    var faceIndices = <int>[];

    switch (face) {
      case 'left':
        vertices.addAll([
          '${x} ${y} ${z}',
          '${x} ${y + 1} ${z}',
          '${x} ${y + 1} ${z + 1}',
          '${x} ${y} ${z + 1}',
        ]);
        break;
      case 'right':
        vertices.addAll([
          '${x + 1} ${y} ${z}',
          '${x + 1} ${y + 1} ${z}',
          '${x + 1} ${y + 1} ${z + 1}',
          '${x + 1} ${y} ${z + 1}',
        ]);
        break;
      case 'bottom':
        vertices.addAll([
          '${x} ${y} ${z}',
          '${x + 1} ${y} ${z}',
          '${x + 1} ${y} ${z + 1}',
          '${x} ${y} ${z + 1}',
        ]);
        break;
      case 'top':
        vertices.addAll([
          '${x} ${y + 1} ${z}',
          '${x + 1} ${y + 1} ${z}',
          '${x + 1} ${y + 1} ${z + 1}',
          '${x} ${y + 1} ${z + 1}',
        ]);
        break;
      case 'front':
        vertices.addAll([
          '${x} ${y} ${z}',
          '${x + 1} ${y} ${z}',
          '${x + 1} ${y + 1} ${z}',
          '${x} ${y + 1} ${z}',
        ]);
        break;
      case 'back':
        vertices.addAll([
          '${x} ${y} ${z + 1}',
          '${x + 1} ${y} ${z + 1}',
          '${x + 1} ${y + 1} ${z + 1}',
          '${x} ${y + 1} ${z + 1}',
        ]);
        break;
    }

    for (var vertex in vertices) {
      if (uniqueVertices.containsKey(vertex)) {
        faceIndices.add(uniqueVertices[vertex]!);
      } else {
        uniqueVertices[vertex] = currentVertexIndex;
        vertexList.add('v $vertex');
        faceIndices.add(currentVertexIndex++);
      }
    }

    return 'f ${faceIndices[0]} ${faceIndices[1]} ${faceIndices[2]} ${faceIndices[3]}\n';
  }
}
