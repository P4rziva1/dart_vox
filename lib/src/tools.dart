import 'dart:io';
import 'dart:typed_data';

import 'package:dart_vox/src/constants.dart';
import 'package:dart_vox/src/models/material.dart';
import 'package:dart_vox/src/models/voxel.dart';
import 'package:dart_vox/src/parser.dart';

void inspectChunks(Uint8List bytes) {
  List<String> chunks = [];
  int offset = 0;
  while (offset < bytes.length) {
    String chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    chunks.add(chunkId);
    offset += VALUE_SIZE;
    switch (chunkId) {
      case 'VOX ':
        offset += VALUE_SIZE;
        break;

      default:
        print(chunkId);
        int chunkSize = getInt(bytes, offset);
        offset += VALUE_SIZE;
        print('chunk: $chunkSize');
        int childSize = getInt(bytes, offset);
        print('child: $childSize');
        offset += VALUE_SIZE;
        offset += chunkSize;
    }
  }
  var map = {};

  for (var element in chunks) {
    if (!map.containsKey(element)) {
      map[element] = 1;
    } else {
      map[element] += 1;
    }
  }

  print(map);
  print(chunks);
}

dynamic bytesToChunkMap(Uint8List bytes) {
  Map<String, Map<String, String>> chunks = {};
  int offset = 0;
  while (offset < bytes.length) {
    String chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    offset += VALUE_SIZE;
    switch (chunkId) {
      case 'VOX ':
        int value = getInt(bytes, offset);
        offset += VALUE_SIZE;
        chunks[chunkId] = {
          'version': value.toString(),
        };
        break;

      default:
        int chunkSize = getInt(bytes, offset);
        offset += VALUE_SIZE;
        int childSize = getInt(bytes, offset);
        offset += VALUE_SIZE;
        offset += chunkSize;
        chunks[chunkId] = {
          'chunkSize': chunkSize.toString(),
          'childSize': childSize.toString(),
        };
    }
  }
  return chunks;
}

void toFile(List list) {
  String contents = '';
  for (int i = 0; i < list.length; i++) {
    contents += '${list[i]}${i < list.length - 1 ? '\n' : ''}';
  }
  File file = File('debug.txt');
  file.writeAsStringSync(contents);
}

List<Material> parseMATL(Uint8List bytes) {
  int offset = 0;
  int materialId = getInt(bytes, 0);
  offset += VALUE_SIZE;
  final materialDict = getDict(bytes.sublist(offset));
  return [];
}

List<String> parseNOTE(Uint8List bytes) {
  int offset = 0;
  int numColors = getInt(bytes, 0);
  print(numColors);
  offset += VALUE_SIZE;
  List<String> notes = [];
  for (int i = 0; i < numColors; i++) {
    int length = getInt(bytes, offset);
    offset += VALUE_SIZE;
    String note = String.fromCharCodes(bytes.sublist(offset, offset + length));
    offset += length;
    notes.add(note);
  }
  return notes;
}

List<Voxel> parseXYZI(Uint8List bytes) {
  List<Voxel> voxels = [];
  int offset = 0;
  for (int i = 0; i < bytes.length / VALUE_SIZE; i++) {
    int x = bytes[offset];
    offset++;
    int y = bytes[offset];
    offset++;
    int z = bytes[offset];
    offset++;
    int color = bytes[offset];
    offset++;
    voxels.add(Voxel(x, y, z, color));
  }
  return voxels;
}

void parseSIZE(Uint8List bytes) {
  int offset = 0;
  int sizeX = getInt(bytes, offset);
  offset += VALUE_SIZE;
  int sizeY = getInt(bytes, offset);
  offset += VALUE_SIZE;
  int sizeZ = getInt(bytes, offset);
  offset += VALUE_SIZE;
  print('{x: $sizeX, y: $sizeY, z: $sizeZ}');
}

String getString(Uint8List bytes) {
  int offset = 0;
  int length = getInt(bytes, 0);
  offset += VALUE_SIZE;
  return String.fromCharCodes(bytes.sublist(offset, offset + length));
}

(Map<String, String>, int) getDict(Uint8List bytes) {
  int offset = 0;
  int pairs = getInt(bytes, 0);
  Map<String, String> dict = {};
  offset += VALUE_SIZE;
  for (int i = 0; i < pairs; i++) {
    int length = getInt(bytes, offset);
    offset += VALUE_SIZE;
    String key = String.fromCharCodes(bytes.sublist(offset, offset + length));
    offset += length;
    length = getInt(bytes, offset);
    offset += VALUE_SIZE;
    String value = String.fromCharCodes(bytes.sublist(offset, offset + length));
    offset += length;
    dict[key] = value;
  }
  return (dict, offset);
}
