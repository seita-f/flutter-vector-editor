import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'shape/shape.dart';

class FileManager {

  static Future<File?> saveShapes(List<Shape> shapes, String fileName) async {
    if (shapes.isEmpty) {
      print("No shapes to save.");
      return null; // Early return if there are no shapes
    }
    print("shapes are not null :)");
    String data = json.encode(shapes.map((shape) => shape.toJson()).toList());
    File file = File(fileName);
    await file.writeAsString(data);
  }

  static Future<List<Shape>> loadShapes(String filePath) async {
    File file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File does not exist: $filePath');
    }
    String contents = await file.readAsString();
    List<dynamic> jsonData = json.decode(contents);
    List<Shape> shapes = jsonData.map((item) => Shape.fromJson(item)).whereType<Shape>().toList();
    return shapes;
  }
}
