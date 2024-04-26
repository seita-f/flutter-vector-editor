import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // menubar for mac
import 'dart:ui' as ui;
import 'dart:async';
import 'package:file_picker/file_picker.dart';  // FilePicker
import 'dart:io';
import 'dart:math';

// files
import 'points.dart';
import 'shape/shape.dart';
import 'shape/line.dart';
import 'shape/circle.dart';
import 'fileManager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Draw App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      );
    }
  }

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Color> colors = [
    Colors.black,
    Colors.grey,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];

  String shapeType = 'Line'; // Default shape

  // Properties
  double currentThickness = 4;
  Color currentColor = Colors.black;  // default
  Color canvasColor = Color(0xFFF5F5F5);
  int id = 0;

  // Flag for drawing
  bool drawingLine = true; // defualt
  bool drawingPolygon = false;
  bool drawingCircle = false;
  bool antiAliased = false;
 
  // Flag for editing
  bool shape_edit = false;
  bool contain = false;
  bool shape_isSelected = false;
  bool movingVertex = false;
  bool movingLocation = false;
  
  Shape? selectedShape = null;

  // Point
  List<Point> points = List<Point>.empty(growable: true);
  List<Shape> shapes = List<Shape>.empty(growable: true);
  Point startPoint = Point(0, 0);  // Initialize with default values
  Point endPoint = Point(0, 0);
  Point previousCursorPosition = Point(0, 0);
  Point currentCursorPosition = Point(0, 0);

  // Index
  int currentShapeIndex = -1;
  int currentEdgeIndex = -1;
  int currentVertexIndex = -1;

  void startDrawing(DragStartDetails details) {
    print("startDrawing() is called!");

    setState(() {

      if(!shape_isSelected){
        points.add(offsetToPoint(details.localPosition));
        // print("${details.localPosition} \n");
      }
      else{
        Point temp = Point(details.localPosition.dx, details.localPosition.dy);

        if (selectedShape != null) {
            if ((selectedShape?.contains(temp) == true) && (selectedShape?.isStartPoint(temp) == false)) {   
              movingVertex = true;
              movingLocation = false;
              print("moving vertex is true\n");
            }else if ((selectedShape?.contains(temp) == true) && (selectedShape?.isStartPoint(temp) == true)) {
              movingLocation = true;
              movingVertex == false;
              print("moving location is true\n");
            }
        }
      }
    });
  }

  void continueDrawing(DragUpdateDetails details) {
    // print("continueDrawing is called!");
    setState(() {

    });
  }

  void stopDrawing(DragEndDetails details) {
    print("stopDrawing() is called!");
    setState(() {
      
      print("shape_isSelected $shape_isSelected \n");
      if(!shape_isSelected){
        points.add(offsetToPoint(details.localPosition));
        print(details.localPosition);

        if(drawingLine){
          shapes.add(Line(points, currentThickness.toInt(), currentColor, id));
          id += 1;
          points.clear();
        }
        else if(drawingCircle){
          shapes.add(Circle(points, currentThickness.toInt(), currentColor, id));
          id += 1;
          points.clear();
        }
        else if(drawingPolygon){
          // drawing polygon
        }
        print("$shapes \n");
      }
      else{
        if(movingVertex == true){ // moving end point
            
            if(selectedShape?.radius != null)
            {
              selectedShape?.end_dx = details.localPosition.dx;
              selectedShape?.end_dy = details.localPosition.dy;
              int? updated_radius = (sqrt(pow((details.localPosition.dx - selectedShape?.start_dx), 2) + pow((details.localPosition.dy - selectedShape?.start_dy), 2) )).toInt();

              selectedShape?.color = currentColor;
              selectedShape?.thickness = currentThickness.toInt();

              if (updated_radius != null) {
                selectedShape!.radius = updated_radius;
              }

              print("moving-end point called!\n");
              for (var shape in shapes) {
                if (selectedShape?.getId() == shape.getId()) {
                  if (selectedShape != null) {
                    shape = selectedShape!;
                  }               
                }
              }
            }
            movingVertex = false;
            movingLocation = false;
        }
        else if(movingLocation == true){ // moving start point
            if(selectedShape?.radius != null)
            {
              int? original_radius = selectedShape?.radius;   // keep original radius

              selectedShape?.start_dx = details.localPosition.dx;
              selectedShape?.start_dy = details.localPosition.dy;
              selectedShape?.color = currentColor;
              selectedShape?.thickness = currentThickness.toInt();

              if (original_radius != null) {
                selectedShape!.radius = original_radius;
              }
              print("moving start-point!! \n");
              for (var shape in shapes) {
                if (selectedShape?.getId() == shape.getId()) {
                  if (selectedShape != null) {
                    shape = selectedShape!;
                  }               
                }
              }  
            } 
            movingVertex = false;
            movingLocation = false;
        }
        shape_isSelected = false;
      }
    });
  }

  deleteSelectedObj(){
    
    if (shape_isSelected && selectedShape != null) {
      shapes.removeWhere((shape) => shape.getId() == selectedShape!.getId());
      selectedShape = null;
      shape_isSelected = false; 
      print("Selected shape has been deleted.");
    }
  }

  // void selectedShape_changeColor(){

  // }

  // void selectedShape_changeThickness(){

  // }

  void isShape(TapUpDetails details)
  {
      // detect if there is a shpe at the tapped location
      print("TapUp() called! It is an edit mode");
      // print(details.localPosition);
      Point tappedPoint = Point(details.localPosition.dx, details.localPosition.dy);

      for (var shape in shapes) {
        if(shape.contains(tappedPoint) == true){
          selectedShape = shape;
          shape_isSelected = true; // update the flag
          print(selectedShape);
        }
      }
  }

  //----- File Manager -----
  void saveFile() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath == null) return; // Exit if no directory selected

    TextEditingController fileNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter File Name'),
          content: TextField(
            controller: fileNameController,
            decoration: InputDecoration(hintText: "File name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                String fileName = fileNameController.text;
                if (fileName.isEmpty) {
                  print("No file name entered.");
                  Navigator.of(context).pop();
                  return;
                }
                String fullPath = '$directoryPath/$fileName';
                Navigator.of(context).pop();
                FileManager.saveShapes(shapes, fullPath).then((file) {
                  if (file != null) {
                    print("File saved to $fullPath");
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  void loadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return; // Exit if no file picked

    String? filePath = result.files.single.path;
    if (filePath == null) {
      print("No file selected.");
      return;
    }
    shapes = await FileManager.loadShapes(filePath);
    setState(() {});
  }

  //----- Functions -----
  Point offsetToPoint(Offset offset) {
    return Point(offset.dx, offset.dy);
  }

  Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;  // 画面のサイズを取得
  }

  @override
  Widget build(BuildContext context) {

    // screen size
    Size size = MediaQuery.of(context).size;  
  
    // ----- Pixel to Image -----
    Uint8List toBytes() {
      final pixels = Uint8List(size.width.toInt() * size.height.toInt() * 4);
    
      for (var i = 0; i < pixels.length; i += 4) {
        pixels[i] = canvasColor.red;
        pixels[i + 1] = canvasColor.green;
        pixels[i + 2] = canvasColor.blue;
        pixels[i + 3] = canvasColor.alpha;
      }

      for (var shape in shapes) {
        shape.draw(pixels, size, isAntiAliased: antiAliased);
      }

      return pixels;
    }

    Future<ui.Image> toImage() {
      final pixels = toBytes();
      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(pixels, size.width.toInt(), size.height.toInt(),
          ui.PixelFormat.rgba8888, completer.complete);
      return completer.future;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Draw App"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: GestureDetector(
              onTapUp: (details) {
                print("Screen tapped");
                isShape(details);
              },
              onPanStart: (details) { startDrawing(details); },
              onPanUpdate: (details) { continueDrawing(details); },
              onPanEnd: (details) { stopDrawing(details); },
              child: Container(
                color: canvasColor,  // キャンバスの色を設定
                child: FutureBuilder<ui.Image>(
                  future: toImage(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Stack(children: [
                        RawImage(
                          alignment: Alignment.topLeft,
                          fit: BoxFit.none,
                          image: snapshot.data!,
                          width: size.width,
                          height: size.height,
                          filterQuality: FilterQuality.none,
                        ),
                      ]);
                    } else {
                      return const SizedBox();
                    }
                  },
                ),  
              ), 
            ),
          ),
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ----- DRAWING BOARD -----
                          Wrap(
                            children: colors.map((color) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  print(currentColor);
                                  print(currentThickness);
                                  setState(() {
                                    currentColor = color;
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: currentColor == color
                                      ? Icon(Icons.check, size: 18, color: Colors.white)
                                      : Container(),
                                ),
                              ),
                            )).toList(),
                          ),
                          // ----- THICKNESS -----
                          Slider(
                            value: currentThickness,
                            min: 1.0,
                            max: 10.0,
                            divisions: 9,
                            label: currentThickness.round.toString(),
                            onChanged: (double value) {
                              setState(() {
                                currentThickness = value;
                              });
                            },
                          ),
                          // ----- SHAPE SELECT -----
                          ToggleButtons(
                            children: <Widget>[
                              Icon(Icons.line_weight), // Line icon
                              Icon(Icons.radio_button_unchecked), // Circle icon
                              Icon(Icons.change_history), // Triangle icon
                            ],
                            isSelected: [shapeType == 'Line', shapeType == 'Circle', shapeType == 'Polygon'],
                            onPressed: (int index) {
                              setState(() {
                                shapeType = ['Line', 'Circle', 'Polygon'][index];
                                if(shapeType == 'Line'){ 
                                  drawingLine = true; 
                                  drawingCircle = false; 
                                  drawingPolygon = false;
                                  shape_edit = false;
                                }
                                if(shapeType == 'Circle'){ 
                                  drawingLine = false; 
                                  drawingCircle = true; 
                                  drawingPolygon = false;
                                  shape_edit = false;
                                }
                                if(shapeType == 'Polygon')
                                { drawingLine = false; 
                                  drawingCircle = false; 
                                  drawingPolygon = true;
                                  shape_edit = false;
                                }
                              });
                            },
                          ),
                          Row(
                            children: [
                              // ------ Edit button -----
                              Expanded(
                                child: IconButton(
                                  icon: Icon(Icons.edit),
                                  color: shape_edit ? Colors.purple : Colors.black, 
                                  onPressed: () {
                                    // Add eraser functionality here
                                    setState(() {
                                      shapeType = ''; // shapeType を空にリセットする
                                      shape_edit = true; 
                                      drawingLine = false; 
                                      drawingCircle = false; 
                                      drawingPolygon = false;
                                      print("shape_edit clicked! $shape_edit");
                                    });
                                  },
                                ),
                              ),
                              // ----- DELETE ALL -----
                              Expanded(
                                child: TextButton.icon(
                                  icon: Icon(Icons.delete_outline, color: Colors.black),
                                  label: Text('Delete All', style: TextStyle(color: Colors.black)),
                                  onPressed: () {
                                    // Add eraser functionality for deleting all shapes
                                    setState(() {
                                      shapes.clear();  // Clears all shapes
                                      id = 0;
                                      print("Deleted all shapes!");
                                    });
                                  },
                                ),
                              ),
                              // ----- DELETE INDIVIDUAL SHAPE -----
                              Expanded(
                                child: TextButton.icon(
                                  icon: Icon(Icons.delete_forever, color: Colors.black),
                                  label: Text('Delete Selected', style: TextStyle(color: Colors.black)),
                                  onPressed: () {
                                    // Add eraser functionality for deleting selected shape
                                    setState(() {
                                      deleteSelectedObj();
                                    });
                                  },
                                ),
                              ),
                              // ----- ANTIALIASED -----
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text('Anti-Aliasing ON'),
                                  value: true,
                                  groupValue: antiAliased,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      antiAliased = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text('Anti-Aliasing OFF'),
                                  value: false,
                                  groupValue: antiAliased,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      antiAliased = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      child: Text("Load"),
                                      onPressed: () {
                                        loadFile();
                                      },
                                    ),
                                    ElevatedButton(
                                      child: Text("Save"),
                                      onPressed: () {
                                        saveFile();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
