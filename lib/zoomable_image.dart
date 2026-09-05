import 'package:flutter/material.dart';

class ZoomableImage extends StatefulWidget {
  final String imagePath;
  final double maxScale;
  final double zoomScale; // Во сколько раз увеличивать при двойном тапе

  const ZoomableImage({
    super.key,
    required this.imagePath,
    this.maxScale = 3.0,
    this.zoomScale = 3.0,
  });

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage>
    with SingleTickerProviderStateMixin {
  
  late final TransformationController _transformationController;
  late final AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    final Matrix4 currentMatrix = _transformationController.value;
    final double currentScale = currentMatrix.getMaxScaleOnAxis();
    
    // Используем zoomScale из параметров виджета
    final double targetScale = currentScale > 1.5 ? 1.0 : widget.zoomScale;

    Matrix4 targetMatrix;

    if (targetScale == 1.0) {
      targetMatrix = Matrix4.identity();
    } else {
      final Offset tapPosition = details.localPosition;
      final translation = currentMatrix.getTranslation();
      
      final double newTranslationX = translation.x + tapPosition.dx * (currentScale - targetScale);
      final double newTranslationY = translation.y + tapPosition.dy * (currentScale - targetScale);
      
      targetMatrix = Matrix4.identity()
        ..translate(newTranslationX, newTranslationY)
        ..scale(targetScale);
    }

    _animation = Matrix4Tween(
      begin: currentMatrix,
      end: targetMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: widget.maxScale,
        child: Image.asset(widget.imagePath),
      ),
    );
  }
}