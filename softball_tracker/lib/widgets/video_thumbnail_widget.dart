import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:softball_tracker/utils/review_arguments.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final File video;
  final int index;

  const VideoThumbnailWidget(
      {super.key, required this.video, required this.index});

  @override
  State<StatefulWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final image = await VideoThumbnail.thumbnailData(
      video: widget.video.path,
      quality: 50,
    );
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(10),
      tileColor: widget.index % 2 == 0 ? Colors.white : Colors.grey[300],
      leading: _image != null
          ? Image.memory(_image!)
          : const CircularProgressIndicator(), // Show a loader until the image is ready
      title: Text(
        DateTime.fromMillisecondsSinceEpoch(
          int.parse(
            RegExp(r'_(\d+)\.')
                    .firstMatch(widget.video.path.split('/').last)
                    ?.group(1) ??
                "0",
          ),
        ).toString(),
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          "/review",
          arguments: ReviewArguments(widget.video),
        );
      },
    );
  }
}
