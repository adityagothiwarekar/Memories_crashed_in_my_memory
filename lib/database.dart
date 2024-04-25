import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:assignment_one/database.dart';

Future<Database> openCustomDatabase() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'image_location_database.db');

  // Open the database using sqflite's openDatabase function
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE images(id INTEGER PRIMARY KEY AUTOINCREMENT, imagePath TEXT, city TEXT)',
      );
    },
  );
}

class Memory {
  final String imagePath;
  final String city;


  Memory({required this.imagePath, required this.city});
}

Future<List<Memory>> retrieveMemoriesFromDatabase() async {
  final Database database = await openCustomDatabase();

  // Query the database for all rows from the 'images' table
  final List<Map<String, dynamic>> rows = await database.query('images');

  // Map the rows to Memory objects
  return rows.map((row) => Memory(imagePath: row['imagePath'], city: row['city'])).toList();
}
