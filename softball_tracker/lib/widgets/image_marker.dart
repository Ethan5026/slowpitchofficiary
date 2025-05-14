import 'package:flutter/material.dart';

class ImageMarker extends StatefulWidget {
  final void Function(List<double>)? onMarked;
  final Image image;

  const ImageMarker({Key? key, this.onMarked, required this.image}) : super(key: key);

  @override
  State<ImageMarker> createState() => _ImageMarkerState();
}

class _ImageMarkerState extends State<ImageMarker> {
  double? imageWidth;
  double? imageHeight;
  final double scale = 0.3;
  Offset? tapPosition;

  @override
  void initState() {
    super.initState();
    _resolveImageSize();
  }

  void _resolveImageSize() {
    widget.image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        if (mounted) {
          setState(() {
            imageWidth = info.image.width.toDouble();
            imageHeight = info.image.height.toDouble();
          });
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageWidth == null || imageHeight == null) {
      return const Center(child: CircularProgressIndicator());
    }


    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: imageWidth! * scale,
            height: imageHeight! * scale,
            child: GestureDetector(
              onTapUp: (TapUpDetails details) {
                setState(() {
                  tapPosition = details.localPosition;
                });

                final double x = details.localPosition.dx / scale;
                final double y = details.localPosition.dy / scale;
                print("Tap Detected: ($x, ${imageHeight! - y}");
                widget.onMarked?.call([x, imageHeight! - y]);
              },
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: widget.image,
                ),
              ),
            ),
          ),
          if (tapPosition != null)
            Positioned(
              left: tapPosition!.dx - 10,
              top: tapPosition!.dy - 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
