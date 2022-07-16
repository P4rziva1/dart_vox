enum MaterialType { diffuse, metal, glass, emit }

class Material {
  static Map<String?, MaterialType?> typeMap = {
    '_metal': MaterialType.metal,
    '_emit': MaterialType.emit,
    '_glass': MaterialType.glass,
    '_diffuse': MaterialType.diffuse,
    null: null,
  };
  final int id;
  MaterialType? type;
  double? weight;
  double? roughness;
  double? ior;

  Material({
    required this.id,
    this.type,
    this.roughness,
    this.ior,
  });

  factory Material.fromId(int id) {
    return Material(id: id, roughness: 0.1, ior: 0.3);
  }

  factory Material.fromMap(int id, Map<String, String> map) {
    return Material(
        id: id,
        type: typeMap[map['_type']],
        ior: map['_ior'] as double,
        roughness: map['_rough'] as double);
  }
}
