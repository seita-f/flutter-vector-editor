import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // menubar for mac
import 'dart:ui' as ui;
import 'dart:async';
import 'package:file_picker/file_picker.dart';  // FilePicker
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'dart:math' as math;

// files
import 'points.dart';
import 'fileManager.dart';
import 'image.dart';

import 'shape/shape.dart';
import 'shape/line.dart';
import 'shape/circle.dart';
import 'shape/polygon.dart';
import 'shape/rectangle.dart';


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
    Color(0xFFF5F5F5), // background color to reset the fill color
  ];

  String shapeType = 'Line'; // Default shape

  // Properties
  double currentThickness = 4;
  Color currentColor = Colors.black;  // default
  Color currentFillColor = Color(0xFFF5F5F5); // dafault
  Color canvasColor = Color(0xFFF5F5F5);
  int id = 0;
  int n_circle = 1; // default

  // Flag for drawing
  bool drawingLine = true; // defualt
  bool drawingPolygon = false;
  bool drawingCircle = false;
  bool drawingRectangle = false;
  bool antiAliased = false;
  
  // Flag for editing
  bool shape_edit = false;
  bool contain = false;
  bool shape_isSelected = false;
  bool movingVertex = false;
  bool movingLocation = false;
  bool isPlygonClosed = false;
  bool isFillColor = false;
  bool isFillImage = false;
  bool isClipping = false;
  Shape? selectedShape = null;
  ImageData? fillImage;
  ui.Image? decodedImage;
 
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


  void startDrawing(DragStartDetails details) {
    print("startDrawing() is called!");

    setState(() {
      
      // adding point to Point List to draw shape
      if(!shape_isSelected && isClipping == false){
        if(!drawingPolygon){
          points.add(offsetToPoint(details.localPosition));
        }else{
          // polygon case
          print("start point: ${details.localPosition} is added to polygonPoints \n");
          polygonPoints.add(offsetToPoint(details.localPosition));
        }
        
        // print("${details.localPosition} \n");
      }
      else if(shape_isSelected && isClipping == true){
        if(drawingRectangle){
          print("%%%%%% drawing Clipping Rectangle is called! %%%%%%\n");
          print(points);
          points.clear();
          points.add(offsetToPoint(details.localPosition));
        }
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

  double calc_distance(Point point1, Point point2){
    return math.sqrt(math.pow(point1.dx - point2.dx, 2) + math.pow(point1.dy - point2.dy, 2));
    // double dist = math.sqrt(math.pow(point1.dx - point2.dx, 2) + math.pow(point1.dy - point2.dy, 2));
    // return dist;
  }

  // check if the start point is closed to the last point
  bool isClosed(Point point1, Point point2){
    final distance = calc_distance(point1, point2);
    // print("isClosed distance: $distance");
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
            shapes.add(Polygon(polygonPoints, currentThickness.toInt(), currentColor, id, currentFillColor));
          }

          // DEBUG
          // print("======== DEBUG =========\n");
          // for (var i = 0; i < polygonPoints.length - 1; i++) {
          //   print("start: (${polygonPoints[i].dx}, ${polygonPoints[i].dy})\n");
          //   print("end: (${polygonPoints[i+1].dx}, ${polygonPoints[i+1].dy})\n");
          // }
          // print("=========================\n");

          // added point is closed to the start point, then closure 
          if(isClosed(polygonPoints[0], polygonPoints[polygonPoints.length-1])){
            print("###### Polygon is closed! ######\n");
            polygonPoints[polygonPoints.length - 1] = polygonPoints[0];
            // 閉じたポリゴンをshapesリストに追加
            shapes.add(Polygon(List.from(polygonPoints), currentThickness.toInt(), currentColor, id, currentFillColor));
            id += 1;
            polygonPoints.clear();
          }
        }
        else if(drawingRectangle){

          if(isClipping == false){
            print("drawing rectangle!\n");
            print(points);
            shapes.add(Rectangle(points, currentThickness.toInt(), currentColor, id));
            id += 1;
            points.clear();
          }
          // else{
          //   // apply clipping algorithm
          //   print("%%%%%%%%%%% clipping method %%%%%%%%%%%%\n");
          //   print(points);
          //   for (var shape in shapes) {
          //     if (selectedShape?.getId() == shape.getId()) {
          //       print("%%%%%%%%%%% GET ID %%%%%%%%%%%% ${selectedShape?.getId()}\n");
          //       if (shape is Polygon) {
  
          //         // print("%%%%%%%%%%% ABOUT TO CLIPP %%%%%%%%%%%%\n"); // Error caused
          //         // shape.clippingRectangle = Rectangle(points, currentThickness.toInt(), currentColor, -10);
          //         // points.clear();
          //       }             
          //     }
          //   }
          // }
        }
      }
      else if(shape_isSelected && drawingRectangle == true){
        // apply clipping algorithm
        points.add(offsetToPoint(details.localPosition));
        print("================ DEBUG ==================\n");
        print("drawing polygon: ${drawingPolygon}\n");
        print("drawing rectangle: ${drawingRectangle}\n");
        print("shape_isSelected: ${shape_isSelected}\n");
        print("%%%%%%%%%%% clipping method %%%%%%%%%%%%\n");
        print(points);
        for (var shape in shapes) {
          if (selectedShape?.getId() == shape.getId()) {
            print("%%%%%%%%%%% GET ID %%%%%%%%%%%% ${selectedShape?.getId()}\n");
            if (shape is Polygon) {
              // print("%%%%%%%%%%% ABOUT TO CLIPP %%%%%%%%%%%%\n"); // Error caused
              shape.clippingRectangle = Rectangle(points, currentThickness.toInt(), currentColor, -10);
            }             
          }
        }
        points.clear();
        print("===========================================\n");
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

  void fillingPolygon() {
    setState(() {
      print("filling methods clicked\n");
      print("selectedShape?.getId(): ${selectedShape?.getId()}\n");
      for (var shape in shapes) {
        if (selectedShape?.getId() == shape.getId()) {
          if (shape is Polygon) {
            if (isFillColor == true) {
              print("Set currentFillColor to the chosen polygon\n");
              print("currentFillColor: ${currentFillColor}\n");
              shape.isFillColor = true;
              shape.isFillImage = false;
              shape.fillColor = currentFillColor;
            }
            if (isFillImage == true) {
              print("Set Image to the chosen polygon\n");
              print("fillImage width: ${fillImage?.width}, height: ${fillImage?.height}\n");
              shape.isFillColor = false;
              shape.isFillImage = true;
              if (fillImage != null) {
                print("fillImage data length: ${fillImage!.pixels.length}\n");
              }
              // shape.fillImage = fillImage;
            }
          }
        }
      }
    });
  }

  void deleteAll(){
    shapes.clear();  // Clears all shapes
    polygonPoints.clear();
    id = 0;
    currentFillColor = Color(0xFFF5F5F5); // back to dafault
    fillImage = null;
    print("Deleted all shapes!");
  }

  void deleteSelectedObj(){
    
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

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return; // Exit if no file picked

    String? filePath = result.files.single.path;
    if (filePath == null) {
      print("No file selected.");
      return;
    }

    final Uint8List imageData = await File(filePath).readAsBytes();
    final Image imageFile = Image.memory(imageData);

    // Get image dimensions
    final Completer<ui.Image> completer = Completer();
    imageFile.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }),
    );

    final ui.Image uiImage = await completer.future;
    print("Loaded image width: ${uiImage.width}, height: ${uiImage.height}");

    // Convert to RGBA format
    final ByteData? byteData = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      print("Failed to convert image to RGBA format.");
      return;
    }
    setState(() {
      fillImage = ImageData(byteData.buffer.asUint8List(), uiImage.width, uiImage.height);
      fillingPolygon();
    });
  }

  // decode image from pixels to display in the box
  Future<ui.Image> decodeImageFromPixels(Uint8List pixels, int width, int height) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (ui.Image img) {
        completer.complete(img);
      },
    );
    return completer.future;
  }

  Future<void> _convertImage() async {
    if (fillImage != null) {
      final ui.Image image = await decodeImageFromPixels(
        fillImage!.pixels,
        fillImage!.width,
        fillImage!.height,
      );
      setState(() {
        decodedImage = image;
      });
    }
  }

  @override
  void didUpdateWidget(covariant MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (fillImage != null) {
      _convertImage();
    }
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
                          // ----- COLOR PALETTE, THICKNESS SLIDER, SHAPE SELECT ALL IN ONE ROW -----
                          Wrap(
                            spacing: 8.0, // Horizontal space between the children
                            runSpacing: 4.0, // Vertical space between the lines
                            children: [
                              // Color Palette
                              PopupMenuButton<Color>(
                                initialValue: currentColor,
                                onSelected: (Color color) {
                                  setState(() {
                                    currentColor = color;
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: currentColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                itemBuilder: (BuildContext context) {
                                  return colors.map((Color color) {
                                    return PopupMenuItem<Color>(
                                      value: color,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: currentColor == color ? Colors.black : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                              
                              // Thickness Slider
                              Container(
                                width: 300,  // Fixed width for the slider
                                child: Slider(
                                  value: currentThickness,
                                  min: 1.0,
                                  max: 10.0,
                                  divisions: 9,
                                  label: currentThickness.round().toString(),
                                  onChanged: (double value) {
                                    setState(() {
                                      currentThickness = value;
                                    });
                                  },
                                ),
                              ),
                              
                              // Shape Selector Icons
                              ...['Line', 'Circle', 'Polygon', 'Rectangle'].map((shape) => InkWell(
                                onTap: () {
                                  setState(() {
                                    shapeType = shape;
                                    drawingLine = shape == 'Line';
                                    drawingCircle = shape == 'Circle';
                                    drawingPolygon = shape == 'Polygon';
                                    drawingRectangle = shape == 'Rectangle';
                                    
                                    isClipping = false;
                                    shape_edit = false;
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: shapeType == shape ? Colors.black : Colors.grey,
                                      width: 2
                                    )
                                  ),
                                  child: Icon(
                                    shape == 'Line' ? Icons.line_weight :
                                    shape == 'Circle' ? Icons.radio_button_unchecked :
                                    shape == 'Polygon' ? Icons.change_history :
                                    Icons.crop_square,  // Icon for Rectangle
                                    color: shapeType == shape ? Colors.blue : Colors.black,
                                  ),
                                ),
                              )),

                              // Adding space
                              SizedBox(width: 10.0),
                              // Label "Fill Color"
                              // Text('Fill Color:'),
                              
                              // Color Palette for fill color
                              PopupMenuButton<Color>(
                                initialValue: currentFillColor,
                                onSelected: (Color color) {
                                  setState(() {
                                    currentFillColor = color;
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: currentFillColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                itemBuilder: (BuildContext context) {
                                  return colors.map((Color color) {
                                    return PopupMenuItem<Color>(
                                      value: color,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: currentFillColor == color ? Colors.black : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                              // Fill with image button
                              ElevatedButton(
                                onPressed: () {
                                  // Implement functionality to fill the shape with an image
                                  isFillColor = true;
                                  isFillImage = false;
                                  fillingPolygon();
                                },
                                child: Text('Fill with Color'),
                              ),
                              // display current chosen image
                              // Container(
                              //   width: 35,
                              //   height: 35,
                              //   decoration: BoxDecoration(
                              //     border: Border.all(color: Colors.black),
                              //   ),
                              //   child: fillImage != null
                              //       ? Image.memory(
                              //           fillImage!.pixels,
                              //           fit: BoxFit.cover,
                              //         )
                              //       : Center(child: Text('X')),
                              // ),
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                ),
                                child: fillImage != null
                                    ? FutureBuilder<ui.Image>(
                                        future: decodeImageFromPixels(
                                          fillImage!.pixels,
                                          fillImage!.width,
                                          fillImage!.height,
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.done &&
                                              snapshot.hasData) {
                                            return RawImage(
                                              image: snapshot.data,
                                              fit: BoxFit.cover,
                                            );
                                          } else if (snapshot.hasError) {
                                            return Center(child: Text('Error loading image'));
                                          } else {
                                            return Center(child: CircularProgressIndicator());
                                          }
                                        },
                                      )
                                    : Center(child: Text('X')),
                              ),
                              ElevatedButton(
                                onPressed: (){
                                  isFillColor = false;
                                  isFillImage = true;
                                  _pickImage();
                                },
                                child: Text('Fill with Image'),
                              ),
                              ElevatedButton(
                                onPressed: (){
                                  shapeType = 'Rectangle';
                                  isClipping = true; // true
                                  shape_edit = false; 
                                  drawingLine = false; 
                                  drawingCircle = false; 
                                  drawingPolygon = false;
                                  drawingRectangle = true;  // true
                                },
                                child: Text('Set Clipping Rectangle'),
                              ),
                            ],
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
                                      drawingRectangle = false;
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
                                      deleteAll();
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
