import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // menubar for mac
import 'dart:ui' as ui;
import 'dart:async';
import 'package:file_picker/file_picker.dart';  // FilePicker
import 'dart:io';
import 'dart:math';
import 'dart:math' as math;

// files
import 'points.dart';
import 'shape/shape.dart';
import 'shape/line.dart';
import 'shape/circle.dart';
import 'shape/polygon.dart';
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
  int n_circle = 1; // default

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
  bool isPlygonClosed = false;
  Shape? selectedShape = null;

  // Point
  List<Point> points = List<Point>.empty(growable: true);
  List<Point> polygonPoints = List<Point>.empty(growable: true);
  List<Polygon> completedPolygons = [];  // これは描かれたすべてのポリゴンを保持します。

  List<Shape> shapes = List<Shape>.empty(growable: true);
  Point startPoint = Point(0, 0);  // Initialize with default values
  Point endPoint = Point(0, 0);
  Point previousToppedPosition = Point(0, 0);

  // Index
  int currentShapeIndex = -1;
  int currentEdgeIndex = -1;
  int currentVertexIndex = -1;

  // File manager
  String? selectedDirectory;
  TextEditingController fileNameController = TextEditingController();

  void startDrawing(DragStartDetails details) {
    print("startDrawing() is called!");

    setState(() {
      
      // adding point to Point List to draw shape
      if(!shape_isSelected){
        if(!drawingPolygon){
          points.add(offsetToPoint(details.localPosition));
        }else{
          // polygon case
          print("start point: ${details.localPosition} is added to polygonPoints \n");
          polygonPoints.add(offsetToPoint(details.localPosition));
        }
        
        // print("${details.localPosition} \n");
      }
      else{ // 

        previousToppedPosition = Point(details.localPosition.dx, details.localPosition.dy); // get the clicked location

        if (selectedShape != null) {
            if ((selectedShape?.contains(previousToppedPosition) == true) && (selectedShape?.isCenterPoint(previousToppedPosition) == false)) {   
              movingVertex = true;
              movingLocation = false;
              print("moving vertex is true\n");
            }else if ((selectedShape?.contains(previousToppedPosition) == true) && (selectedShape?.isCenterPoint(previousToppedPosition) == true)) {
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

  double calc_distance(Point point1, Point point2){
    print("----- calc_distance is called -----\n");
    print("point1: (${point1.dx}, ${point1.dy})\n");
    print("point2: (${point2.dx}, ${point2.dy})\n");
    print("x_diff: ${math.pow(point1.dx - point2.dx, 2)}, y_diff: ${math.pow(point1.dy - point2.dy, 2)} \n");
    print("diff: ${(math.pow(point1.dx - point2.dx, 2) + math.pow(point1.dy - point2.dy, 2))} \n");
    print("distance: ${math.sqrt(math.pow(point1.dx - point2.dx, 2) + math.pow(point1.dy - point2.dy, 2))}\n");
    print("-----------------------------------\n");
    double dist = math.sqrt(math.pow(point1.dx - point2.dx, 2) + math.pow(point1.dy - point2.dy, 2));

    return dist;
  }

  // check if the start point is closed to the last point
  bool isClosed(Point point1, Point point2){
    final distance = calc_distance(point1, point2);
    print("isClosed distance: $distance");
    return distance <= 17;
  }

  void stopDrawing(DragEndDetails details) {
    print("stopDrawing() is called!");
    setState(() {
      
      print("shape_isSelected $shape_isSelected \n");
      if(!shape_isSelected){ // adding the end point to point list
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
          
          print("end point: ${details.localPosition} is added to polygonPoints \n");
          polygonPoints.add(offsetToPoint(details.localPosition));

          if(polygonPoints.length < 3){
            shapes.add(Polygon(polygonPoints, currentThickness.toInt(), currentColor, id));
          }

          // DEBUG
          // print("======== DEBUG =========\n");
          for (var i = 0; i < polygonPoints.length - 1; i++) {
            print("start: (${polygonPoints[i].dx}, ${polygonPoints[i].dy})\n");
            print("end: (${polygonPoints[i+1].dx}, ${polygonPoints[i+1].dy})\n");
          }
          // print("=========================\n");

          // added point is closed to the start point, then closure 
          if(isClosed(polygonPoints[0], polygonPoints[polygonPoints.length-1])){
            print("###### Polygon is closed! ######\n");
            polygonPoints[polygonPoints.length - 1] = polygonPoints[0];
            // 閉じたポリゴンをshapesリストに追加
            shapes.add(Polygon(List.from(polygonPoints), currentThickness.toInt(), currentColor, id));
            id += 1;
            polygonPoints.clear();
          }
        }
      }
      else{ // edit mode

        Point newPoint = Point(details.localPosition.dx, details.localPosition.dy);

        if(movingVertex == true) { // moving end point
          
            print("moving-end point called!\n");
            for (var shape in shapes) {
              if (selectedShape?.getId() == shape.getId()) {
                if (selectedShape != null) {
                  // shape = selectedShape!;
                  shape.movingVertex(previousToppedPosition, newPoint, currentColor, currentThickness.toInt());
                }               
              }
            }
            
            movingVertex = false;
            movingLocation = false;
        }
        else if(movingLocation == true){ // moving start point

            // if(selectedShape?.radius != null)  // moving circle
            // {
            //   int? original_radius = selectedShape?.radius;   // keep original radius

            //   selectedShape?.start_dx = details.localPosition.dx;
            //   selectedShape?.start_dy = details.localPosition.dy;
            //   selectedShape?.color = currentColor;
            //   selectedShape?.thickness = currentThickness.toInt();

            //   if (original_radius != null) {
            //     selectedShape!.radius = original_radius;
            //   }
            //   print("moving start-point!! \n");
            //   for (var shape in shapes) {
            //     if (selectedShape?.getId() == shape.getId()) {
            //       if (selectedShape != null) {
            //         shape = selectedShape!;
            //       }               
            //     }
            //   }  
            // } 
            print("moving shape called!\n");
            for (var shape in shapes) {
              if (selectedShape?.getId() == shape.getId()) {
                if (selectedShape != null) {
                  // shape = selectedShape!;
                  shape.movingShape(previousToppedPosition, newPoint, currentColor, currentThickness.toInt());
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
                                shapeType = ['Line', 'Circle', 'Polygon',][index];
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
                              // ----- Number selection dropdown -----
                              // Expanded(
                              //   child: DropdownButton<int>(
                              //     value: n_circle,
                              //     onChanged: (int? newValue) {
                              //       setState(() {
                              //         n_circle = newValue!;
                              //         print("N: $n_circle \n");
                              //       });
                              //     },
                              //     items: List.generate(5, (index) {
                              //       return DropdownMenuItem<int>(
                              //         value: index + 1,
                              //         child: Text('${index + 1}'),
                              //       );
                              //     }),
                              //   ),
                              // ),
                              // ----- DELETE ALL -----
                              Expanded(
                                child: TextButton.icon(
                                  icon: Icon(Icons.delete_outline, color: Colors.black),
                                  label: Text('Delete All', style: TextStyle(color: Colors.black)),
                                  onPressed: () {
                                    // Add eraser functionality for deleting all shapes
                                    setState(() {
                                      shapes.clear();  // Clears all shapes
                                      polygonPoints.clear();
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
