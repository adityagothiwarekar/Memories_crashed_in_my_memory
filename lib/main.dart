import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:assignment_one/memories_page.dart';
import 'package:assignment_one/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final databasePath = join(await getDatabasesPath(), 'image_location_database.db');
  print('Database path: $databasePath');
  final database = openDatabase(
    databasePath,
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE images(id INTEGER PRIMARY KEY AUTOINCREMENT, imagePath TEXT, city TEXT)',
      );
    },
    version: 1,
  );
  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final Future<Database> database;

  const MyApp({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(database: database),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Future<Database> database;

  const MyHomePage({Key? key, required this.database}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;
  String? _location;
  late Database _database;

  @override
  void initState() {
    super.initState();
    widget.database.then((value) {
      _database = value;
    });
  }

  Future<void> _takePicture() async {
    final imageFile = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _imageFile = File(imageFile!.path);
    });
  }

  Future<void> _selectLocation(BuildContext context) async {
    final pickedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Select Location'),
          ),
          body: FlutterLocationPicker(
            initZoom: 11,
            minZoomLevel: 5,
            maxZoomLevel: 16,
            trackMyPosition: true,
            searchBarBackgroundColor: Colors.white,
            selectedLocationButtonTextstyle: const TextStyle(fontSize: 18),
            mapLanguage: 'en',
            onError: (e) => print(e),
            selectLocationButtonLeadingIcon: const Icon(Icons.check),
            showContributorBadgeForOSM: true,
            onPicked: (pickedData) {
              setState(() {
                _location = pickedData.addressData['city'] +
                    ', ' +
                    pickedData.addressData['country'];
              });
              Navigator.pop(context); // Close location picker screen
            },
          ),
        ),
      ),
    );
  }

  Future<void> _uploadData(BuildContext context) async {
    if (_imageFile == null || _location == null) {
      // Show error message if image or location is not selected
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select image and location first.'),
      ));
      return;
    }

    try {
      // Insert data into the database
      await _database.insert(
        'images',
        {'imagePath': _imageFile!.path, 'city': _location},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Data uploaded successfully.'),
      ));
    } catch (e) {
      // Show error message if insertion fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  void _viewMemories(BuildContext context) async {
    final memories = await retrieveMemoriesFromDatabase();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoriesPage(memories: memories),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile == null
                ? Text('No image selected.')
                : Image.file(
              _imageFile!,
              width: 300,
              height: 300,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _takePicture,
              child: Text('Click Image'),
            ),
            SizedBox(height: 20),
            Text(_location ?? 'No location selected.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectLocation(context),
              child: Text('Select Location'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _uploadData(context),
              child: Text('Upload Data'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _viewMemories(context),
              child: Text('View Your Memories'),
            ),
          ],
        ),
      ),
    );
  }
}
