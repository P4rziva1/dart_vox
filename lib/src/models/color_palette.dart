import 'dart:typed_data';

import 'package:dart_vox/src/models/color.dart';

class ColorPalette {
  List<VoxColor> colors;
  //Should not be instantiated
  ColorPalette(this.colors);

  factory ColorPalette.fromColors(List<VoxColor> sourceColors) {
    List<VoxColor> palette = [];
    palette.addAll(sourceColors);
    while (palette.length < 256) {
      palette.add(VoxColor(0, 0, 0, 255));
    }
    return ColorPalette(palette);
  }

  factory ColorPalette.fromBytes(Uint8List bytes) {
    return ColorPalette([]);
  }
}
