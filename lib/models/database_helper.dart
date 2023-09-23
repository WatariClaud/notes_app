import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:notes/models/note.dart';

Future<Database> initializeDatabase() async { // set up db
  final database = await openDatabase(
    join(await getDatabasesPath(), 'notes_db'),
    version: 1,
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database on first instance of app
      return db.execute(
            'CREATE TABLE notes(noteID INTEGER PRIMARY KEY, title TEXT, content TEXT, syncStatus TEXT, isDeleted INTEGER, version INTEGER)',
      );
    },
  );
  return database;
}


Future<void> insertNote(Note note) async {
  // Get a reference to the database.
  final db = await initializeDatabase();
        
  await db.insert(
    'notes',
    note.toMap(), // from component definition (add_note.dart)
    conflictAlgorithm: ConflictAlgorithm.replace, // replace any previous data if duplicate.
  );
}
					
Future<void> updateNote(Note note, noteID) async {
  final db = await initializeDatabase();
  // replace any previous data if duplicate.
  await db.update(
    'notes',
    note.toMap(),
    where: 'noteID = ?',
    whereArgs: [noteID],
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> deleteNote(Note note, noteID) async {
  updateNote(note, noteID); // call above function with local note object as received from click delete icon callback
}

Future<void> syncNote(noteID) async {
  // Get a reference to the database.
  final db = await initializeDatabase();
  // replace any previous data if duplicate.
  await db.update(
    'notes',
    {'syncStatus': 'synced'},
    where: 'noteID = ?',
    whereArgs: [noteID],
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}