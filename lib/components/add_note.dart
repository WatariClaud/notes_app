import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notes/main.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/database_helper.dart';

// Widget to show list of notes
class AddNoteWidget extends StatefulWidget {
	final Database database;
  const AddNoteWidget({Key? key, required this.database}) : super(key: key);

  @override
  State<AddNoteWidget> createState() => AddNote();
}

class AddNote extends State<AddNoteWidget> {
  final titleController = TextEditingController();
  final contentController = TextEditingController(); // controllers to track input field values
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.only(top: 40),
	    color: Colors.white,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // spread children (icons) on screen
            children: [
              GestureDetector( // to make image clickable
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => MyApp(database: widget.database)),
                ),
                child:  Image.asset(
                  'assets/images/back.png',
                  fit: BoxFit.cover, // image scaling
                  width: 50,
                  height: 50,
                ),
              ),
              GestureDetector(
                onTap: () async {
                    var note = Note(
                      title: titleController.text,
                      content: contentController.text,
                      syncStatus: 'unsynced',
                      isDeleted: 0,
                      version: 1,
                    );
                    try {
                      if(note.title != '' && note.content != '') {
                      	await insertNote(note); // from database model helper
                      	// Navigate back to the previous screen (initializing new state to load new note - not used state management or callback as a touch and go)
                      	// ignore: use_build_context_synchronously
                      	Navigator.push(
                        	context,
                        	MaterialPageRoute( builder: (context) => MyApp(database: widget.database)),
                      	);
                      }
                      // will only add and navigate if title and content are not empty

                    } catch (error) {
                      // exceptions that may occur during database operations.
                    if (kDebugMode) {
                      print('Error: $error');
                    }
                    }
                  },
                  child: Image.asset(
                    'assets/images/save.png',
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 70),
            child:  Column(
              children:<Widget> [ // title and content input fields
                Card(
                  elevation: 0,
                  child: TextField(
                    controller: titleController, // track title input value
                    style: const TextStyle(
                      fontSize: 18,
                          fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
			                border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText: 'Title',
                      isDense: true,
                      contentPadding: EdgeInsets.all(17),
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
				           child: TextFormField(
                    controller: contentController,
                    maxLines: null, // multi-line input
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText: 'Type something...', // Placeholder text
                      isDense: true,
                      contentPadding: EdgeInsets.all(17),
                    ),
                  ),
			            )
              ]
	          )
          )
        ],
      ),
    );
  }
}

void main () {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Notes List'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ignore: prefer_typing_uninitialized_variables
          var database;
          return SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: AddNoteWidget(database: database),
            )
          );
        }
      ),
    ),
  ));
}
