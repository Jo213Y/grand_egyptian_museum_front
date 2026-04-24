import 'package:flutter/material.dart';
import 'common_widgets.dart';
import 'img_error.dart'; // لو محتاج GemNetworkImage

class ZoomOverlay extends StatefulWidget {
  final String imageAsset;
  final String imageUrl;
  const ZoomOverlay({required this.imageAsset, required this.imageUrl});

  @override
  State<ZoomOverlay> createState() => _ZoomOverlayState();
}

class _ZoomOverlayState extends State<ZoomOverlay> {
  final TransformationController _controller = TransformationController();

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    } else {
      _controller.value = Matrix4.identity()..scale(3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  transformationController: _controller,
                  minScale: 1,
                  maxScale: 5,
                  child: Image.asset(
                    widget.imageAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => GemNetworkImage(
                      widget.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}