import 'dart:math';

import 'package:dart_vox/src/models/voxel.dart';

List<Voxel> cube(
  int size, {
  int offsetX = 0,
  int offsetY = 0,
  int offsetZ = 0,
}) {
  List<Voxel> voxels = [];
  for (int x = offsetX; x < size + offsetX; x++) {
    for (int y = offsetY; y < size + offsetY; y++) {
      for (int z = offsetZ; z < size + offsetZ; z++) {
        voxels.add(Voxel(x, y, z, 1));
      }
    }
  }
  return voxels;
}

List<Voxel> cubeoid(
  int sizeX,
  int sizeY,
  int sizeZ, {
  int offsetX = 0,
  int offsetY = 0,
  int offsetZ = 0,
  int color = 1,
}) {
  sizeZ = sizeZ.clamp(1, 255);
  List<Voxel> voxels = [];
  for (int x = offsetX; x < sizeX + offsetX; x++) {
    for (int y = offsetY; y < sizeY + offsetY; y++) {
      for (int z = offsetZ; z < sizeZ + offsetZ; z++) {
        voxels.add(Voxel(x, y, z, color));
      }
    }
  }
  return voxels;
}

List<Voxel> randomPlane(
  int sizeX,
  int sizeY, {
  int offsetX = 0,
  int offsetY = 0,
  int color = 1,
}) {
  List<Voxel> voxels = [];
  for (int x = offsetX; x < sizeX + offsetX; x++) {
    for (int y = offsetY; y < sizeY + offsetY; y++) {
      voxels.add(Voxel(x, y, Random().nextInt(5), Random().nextInt(20)));
    }
  }
  return voxels;
}

List<Voxel> diagonalcreateWall({
  required Voxel start,
  required Voxel end,
  required int height,
  required int thickness,
  required int color,
}) {
  List<Voxel> wall = [];

  // Determine the direction of the wall in the x and y axes
  int xDirection = (end.x - start.x).sign;
  int yDirection = (end.y - start.y).sign;

  // Calculate the absolute distances in the x and y directions
  int xDistance = (end.x - start.x).abs();
  int yDistance = (end.y - start.y).abs();

  // Determine the length of the wall based on the larger distance
  int length = (xDistance > yDistance) ? xDistance : yDistance;

  // Loop through the length of the wall
  for (int i = 0; i <= length; i++) {
    int currentX = start.x + i * xDirection;
    int currentY = start.y + i * yDirection;

    // Loop through the height of the wall
    for (int z = 0; z < height; z++) {
      // Loop through the thickness in both directions
      for (int tx = 0; tx < thickness; tx++) {
        for (int ty = 0; ty < thickness; ty++) {
          // Add voxel to the wall list, offset by thickness
          wall.add(Voxel(
            currentX + tx * yDirection, // Offset x by yDirection for thickness
            currentY - ty * xDirection, // Offset y by xDirection for thickness
            z,
            color,
          ));
        }
      }
    }
  }

  return wall;
}

List<Voxel> createWall({
  required Voxel start,
  required Voxel end,
  required int height,
  required int thickness,
  required int color,
}) {
  List<Voxel> wall = [];

  // Determine the direction and distances
  int xDirection = (end.x - start.x).sign;
  int yDirection = (end.y - start.y).sign;
  int xDistance = (end.x - start.x).abs();
  int yDistance = (end.y - start.y).abs();

  int length = (xDistance > yDistance) ? xDistance : yDistance;

  for (int i = 0; i <= length; i++) {
    // Calculate current position along the wall
    int currentX = start.x +
        (xDistance > yDistance
            ? i * xDirection
            : (xDistance == 0 ? 0 : (i * xDirection * xDistance) ~/ length));
    int currentY = start.y +
        (yDistance > xDistance
            ? i * yDirection
            : (yDistance == 0 ? 0 : (i * yDirection * yDistance) ~/ length));

    for (int z = 0; z < height; z++) {
      for (int tx = 0; tx < thickness; tx++) {
        for (int ty = 0; ty < thickness; ty++) {
          // Adjust offsets based on wall orientation
          int offsetX = xDistance > yDistance ? tx : ty;
          int offsetY = yDistance > xDistance ? ty : tx;

          wall.add(Voxel(
            currentX + offsetX * yDirection,
            currentY - offsetY * xDirection,
            z,
            color,
          ));
        }
      }
    }
  }

  return wall;
}
