import 'package:flutter/material.dart';
import 'package:notes/models/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'components/title.dart';
import 'components/notes_list.dart';
import 'package:notes/components/add_note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  final database = await initializeDatabase();

  // Run your app
  runApp(MyApp(database: database)); // Pass the database to your app
}


class MyApp extends StatelessWidget {
  final Database database;

  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
        return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins', // from figma specs
      ),
      debugShowCheckedModeBanner: false,
      title: 'Notes',
      home: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.only(top: 50, bottom: 30, left: 30, right: 30),
            child: Stack( // main app has header and notes list only
              children: <Widget>[
                // render all widgets here
                const HeaderWidget(), 
                NotesListWidget(database: database),
              ],
            )
          )
        ),
        floatingActionButton: Builder( // button to add new note (default flutter floating button)
          builder: (BuildContext context) {
            return FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddNoteWidget(database: database)), // navigate to add note
              ),
              tooltip: 'New Note',
              backgroundColor: const Color.fromRGBO(255, 0, 122, 1.0),
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}
