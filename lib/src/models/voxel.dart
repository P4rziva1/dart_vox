class Voxel {
  final int x;
  final int y;
  final int z;
  final int color;

  Voxel(this.x, this.y, this.z, this.color);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Voxel &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          z == other.z;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;

  @override
  String toString() {
    return 'Voxel($x, $y, $z, $color)';
  }
}
