import 'package:path/path.dart'; // Add this import statement
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class ImageListPage extends StatefulWidget {
  @override
  _ImageListPageState createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  late Database _database;
  late List<Map<String, dynamic>> _imageList = [];

  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  Future<void> _openDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'photo_location.db');

    // Open the database
    _database = await openDatabase(path, version: 1);

    // Fetch images from the database
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    List<Map<String, dynamic>> images = await _database.query('photos');
    setState(() {
      _imageList = images;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image List'),
      ),
      body: _buildImageList(),
    );
  }

  Widget _buildImageList() {
    if (_imageList.isEmpty) {
      return Center(
        child: Text('No images found.'),
      );
    } else {
      return ListView.builder(
        itemCount: _imageList.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> imageData = _imageList[index];
          return ListTile(
            title: Text('Image ${imageData['id']}'),
            subtitle: Text('${imageData['latitude']}, ${imageData['longitude']}'),
            // Display the image here using Image.file or Image.network based on your implementation
          );
        },
      );
    }
  }
}
