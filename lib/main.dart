import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(),
      body: new Column(
        children: <Widget>[
          new SizedBox(height: 100.0, child: new Center(child: new Text("sticky header"))),
          new Expanded(
            child: new PageView(
              children: <Widget>[
                new Container(
                  color: Colors.red,
                  child: new Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: new _Painter(),
                  ),
                ),
                new Container(
                  color: Colors.green,
                  child: new Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: new _Painter(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Painter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PainterState();
}

class _PainterState extends State<_Painter> {
  @override
  Widget build(BuildContext context) => new _PainterRenderObjectWidget();
}

class _PainterRenderObjectWidget extends LeafRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) => new _PainterRenderBox();
}

class _PainterRenderBox extends RenderBox {
  final _lines = new List<Path>();

  // variable to store padding
  Offset padding;

  PanGestureRecognizer _drag;
  Path _currentPath;

  _PainterRenderBox() {
    final GestureArenaTeam team = new GestureArenaTeam();
    _drag = new PanGestureRecognizer()
      ..team = team
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd;
  }

  @override
  bool get sizedByParent => true;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }

  @override
  paint(PaintingContext context, Offset offset) {
    // update padding
    padding = offset;

    final Canvas canvas = context.canvas;

    final Paint paintBorder = new Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withAlpha(128);
    canvas.drawRect(offset & size, paintBorder);

    final Paint paintPath = new Paint()
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..color = Colors.white;
    _lines.forEach((path) {
      canvas.drawPath(path, paintPath);
    });
  }

  void _handleDragStart(DragStartDetails details) {
    final pos = globalToLocal(details.globalPosition) + padding;
    _currentPath = new Path();
    _currentPath?.moveTo(pos.dx, pos.dy);
    _lines.add(_currentPath);
    markNeedsPaint();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final pos = globalToLocal(details.globalPosition) + padding;
    _currentPath?.lineTo(pos.dx, pos.dy);
    markNeedsPaint();
  }

  void _handleDragEnd(DragEndDetails details) {
    _currentPath = null;
    markNeedsPaint();
  }
}