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
