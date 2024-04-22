import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // menubar for mac
import 'dart:ui' as ui;
import 'points.dart';
import 'pixelOperation.dart';
import 'shape/shape.dart';
import 'shape/line.dart';

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
  double currentThickness = 4.0;
  Color currentColor = Colors.black;  // default

  // Flag for drawing
  bool drawingLine = false;
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

  // static const platform = MethodChannel('menu_actions');
  // @override
  // void initState() {
  //   super.initState();
  //   platform.setMethodCallHandler(_handleMethod);
  // }

  // Future<void> _handleMethod(MethodCall call) async {
  //   switch (call.method) {
  //     case 'load':
  //       // Implement your loading logic
  //       break;
  //     case 'save':
  //       // Implement your saving logic
  //       break;
  //     default:
  //       throw PlatformException(
  //         code: 'NotImplemented',
  //         details: 'The method ${call.method} is not implemented',
  //       );
  //   }
  // }

  void startDrawing(DragStartDetails details) {
    // setState(() {
    //   points.add(details.localPosition);
    // });
  }

  void continueDrawing(DragUpdateDetails details) {
    // setState(() {
    //   points.add(details.localPosition);
    // });
  }

  void stopDrawing() {
    setState(() {
      // Add logic if needed when stopping
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Draw App"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: GestureDetector(
              onPanStart: startDrawing,
              onPanUpdate: continueDrawing,
              onPanEnd: (details) => stopDrawing(),
              // child: CustomPaint(
              //   painter: MyPainter(points, currentColor, currentThickness, antiAliased),
              //   child: Container(
              //     color: Colors.white,
              //   ),
              // ),
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
                            label: currentThickness.round().toString(),
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
                                print(shapeType);
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
                                      points.clear();  // Example of erasing all
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

class MyPainter extends CustomPainter {
  final List<Point> points;
  final Color color;
  final double thickness;
  final bool antiAliased;

  MyPainter(this.points, this.color, this.thickness, this.antiAliased);

  @override
  void paint(Canvas canvas, Size size) {
    // Paint paint = Paint()
    //   ..color = color
    //   ..strokeCap = StrokeCap.round
    //   ..strokeWidth = thickness
    //   ..isAntiAlias = antiAliased;

    // for (int i = 0; i < points.length - 1; i++) {
    //   if (points[i] != null && points[i + 1] != null) {
    //     canvas.drawLine(points[i], points[i + 1], paint);
    //   }
    // } 
}

  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}
