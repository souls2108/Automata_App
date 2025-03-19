import 'package:flutter/material.dart';

class InteractiveWidget extends StatefulWidget {
  final Widget child;
  const InteractiveWidget({super.key, required this.child});

  @override
  State<InteractiveWidget> createState() => _InteractiveWidgetState();
}

class _InteractiveWidgetState extends State<InteractiveWidget> {
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;
  final double zoomFactor = 2.0;

  void _handleDoubleTap() {
    final Matrix4 currentMatrix = _transformationController.value;

    if (currentMatrix != Matrix4.identity()) {
      // Reset zoom level
      _transformationController.value = Matrix4.identity();
    } else if (_doubleTapDetails != null) {
      // Zoom in at double-tap location
      final position = _doubleTapDetails!.localPosition;

      final Offset scenePoint = _transformationController.toScene(position);

      final Matrix4 zoomMatrix = Matrix4.identity()
        ..translate(-scenePoint.dx * (zoomFactor - 1),
            -scenePoint.dy * (zoomFactor - 1))
        ..scale(zoomFactor);

      _transformationController.value = zoomMatrix;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 5.0,
        child: widget.child,
      ),
    );
  }
}
