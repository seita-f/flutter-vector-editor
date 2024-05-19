import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'shape/shape.dart';
import 'shape/circle.dart';
import 'shape/line.dart';
import 'shape/rectangle.dart';
import 'shape/polygon.dart';

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

    List<Shape> shapes = jsonData.map((item) {
      if (item['type'] == 'line') {
        return Line.fromJson(item);
      } else if (item['type'] == 'circle') {
        return Circle.fromJson(item);
      }
      else if (item['type'] == 'rectangle') {
        return Rectangle.fromJson(item);
      }
      else if (item['type'] == 'polygon') {
        return Polygon.fromJson(item);
      }
      return null;
    }).whereType<Shape>().toList();
    return shapes;

    // List<Shape> shapes = jsonData.map((item) => Shape.fromJson(item)).whereType<Shape>().toList();
    // return shapes;
  }
}
