import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const todoTABLE = 'Todo'; // Table name constant

class DatabaseProvider {
  // Singleton instance of DatabaseProvider to ensure only one instance is used throughout the app.
  static final DatabaseProvider dbProvider = DatabaseProvider();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await createDatabase();
    return _database!;
  }

  /// Creates the database and initializes it.
  Future<Database> createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "ComManthanTodo.db");

    var database = await openDatabase(path, version: 1, onCreate: initDB);
    return database;
  }

  void initDB(Database database, int version) async {
    // Create the Todo table with an auto-incrementing primary key and necessary fields.
    await database.execute("CREATE TABLE $todoTABLE ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "description TEXT, "
        // SQLITE doesn't have a boolean type, so using INTEGER (0 or 1) to represent boolean values.
        "is_done INTEGER "
        ")");
  }
}
