import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:softball_tracker/widgets/video_thumbnail_widget.dart';

class PastPitchesScreen extends StatefulWidget {
  const PastPitchesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PastPitchesScreenState();
}

class _PastPitchesScreenState extends State<PastPitchesScreen> {
  late List<File> _items = []; // list of cached video references

  @override
  void initState() {
    super.initState();
    loadCachedVideos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadCachedVideos() async {
    final videos = await getCachedVideos();
    setState(() {
      _items = videos;
      _items.sort((a, b) => b.path.compareTo(a.path));
    });
  }

  Future<List<File>> getCachedVideos() async {
    try {
      // retrieve cached video directory path
      final Directory cacheDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = cacheDir.listSync();

      // filter for mp4 videos
      final videoList = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.mp4'))
          .toList();
      return videoList;
    } catch (e) {
      print("Error retrieving videos: $e");
      return List.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Past Pitches"),
        ),
        body: _items.isNotEmpty
            ? ListView.builder(
                itemCount: _items.length, // should be list.length in future
                itemBuilder: (BuildContext context, int index) {
                  final file = _items[index];
                  return VideoThumbnailWidget(video: file, index: index);
                })
            : Container(
                alignment: Alignment.center,
                child: const Text("No Videos!"),
              ));
  }
}
