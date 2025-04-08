import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class WorkoutGallery extends StatefulWidget {
  const WorkoutGallery({super.key});

  @override
  State<WorkoutGallery> createState() => _WorkoutGalleryState();
}

class _WorkoutGalleryState extends State<WorkoutGallery> {
  List<File> _photos = [];
  List<DateTime> _photoDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final workoutDir = Directory('${directory.path}/smartworkouttrainer');

      if (await workoutDir.exists()) {
        final files = await workoutDir.list().toList();
        final photos = <File>[];
        final dates = <DateTime>[];

        for (var file in files) {
          if (file.path.endsWith('.jpg') || file.path.endsWith('.jpeg')) {
            photos.add(File(file.path));
            // Extract date from filename
            final fileName = file.path.split('/').last;
            final timestamp =
                int.tryParse(fileName.split('_')[1].split('.')[0]);
            if (timestamp != null) {
              dates.add(DateTime.fromMillisecondsSinceEpoch(timestamp));
            }
          }
        }

        // Sort photos by date (newest first)
        final sortedIndices = List.generate(photos.length, (i) => i)
          ..sort((a, b) => dates[b].compareTo(dates[a]));

        setState(() {
          _photos = sortedIndices.map((i) => photos[i]).toList();
          _photoDates = sortedIndices.map((i) => dates[i]).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final workoutDir = Directory('${directory.path}/smartworkouttrainer');
        if (!await workoutDir.exists()) {
          await workoutDir.create(recursive: true);
        }

        final fileName = 'workout_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await File(image.path).copy('${workoutDir.path}/$fileName');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo saved successfully')),
          );
          await _loadPhotos();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to take picture')),
        );
      }
    }
  }

  Future<void> _deletePhoto(int index) async {
    try {
      await _photos[index].delete();
      setState(() {
        _photos.removeAt(index);
        _photoDates.removeAt(index);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete photo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _takePhoto,
            tooltip: 'Take New Photo',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.photo_library,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No photos yet',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take First Photo'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.file(
                                  _photos[index],
                                  fit: BoxFit.contain,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    DateFormat('MMM dd, yyyy')
                                        .format(_photoDates[index]),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _deletePhoto(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _photos[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(128),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                DateFormat('MMM dd').format(_photoDates[index]),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
