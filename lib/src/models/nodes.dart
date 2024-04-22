class TransformNode {
  final int id;
  final int childId;
  final Translation translation;

  TransformNode(
      {required this.id, required this.childId, required this.translation});
}

class GroupNode {
  final int id;
  final List<int> childrenIds;

  GroupNode({required this.id, required this.childrenIds});
}

class ShapeNode {
  final int id;
  final int modelId;

  ShapeNode({required this.id, required this.modelId});
}

class Translation {
  final int x;
  final int y;
  final int z;

  const Translation(this.x, this.y, this.z);
}
