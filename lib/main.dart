import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // menubar for mac
import 'dart:ui' as ui;
import 'dart:async';

// files
import 'points.dart';
import 'pixelOperation.dart';
import 'shape/shape.dart';
import 'shape/line.dart';
import 'shape/circle.dart';

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

  // Flag for drawing
  bool drawingLine = true; // defualt
  bool drawingPolygon = false;
  bool drawingCircle = false;

  // Flag for editing
  bool movingVertex = false;
  bool movingEdge = false;
  bool movingShape = false;
  bool modifyingShape = false;
  bool antiAliased = false;
  
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
      points.add(offsetToPoint(details.localPosition));
      print(details.localPosition);
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
      // Add logic if needed when stopping
      points.add(offsetToPoint(details.localPosition));
      print(details.localPosition);

      if(drawingLine){
        shapes.add(Line(points, currentThickness.toInt(), currentColor));
        points.clear();
      }
      else if(drawingCircle){
        shapes.add(Circle(points, currentThickness.toInt(), currentColor));
        points.clear();
      }
      else if(drawingPolygon){

      }
      print(shapes);
    });
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
              // onTap: () {
              //   print("Screen tapped");
              // },
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
                        // Text(drawing.toString())
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
                              Icon(Icons.line_weight),
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
                                }
                                if(shapeType == 'Circle'){ 
                                  drawingLine = false; 
                                  drawingCircle = true; 
                                  drawingPolygon = false;
                                }
                                if(shapeType == 'Polygon'){
                                  drawingLine = false; 
                                  drawingCircle = false; 
                                  drawingPolygon = true;
                                }
                              });
                            },
                          ),
                          Row(
                            children: [
                              // ----- DELETE -----
                              Expanded(
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    // Add eraser functionality here
                                    setState(() {
                                      // points.clear();  // Example of erasing all
                                      shapes.clear();
                                      print("Deleted all shapes!");
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
                                        // Load functionality
                                      },
                                    ),
                                    ElevatedButton(
                                      child: Text("Save"),
                                      onPressed: () {
                                        // Save functionality
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
