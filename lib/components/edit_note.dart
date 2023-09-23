import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'package:notes/main.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/database_helper.dart';

// Widget to edit a notes
class EditNoteWidget extends StatefulWidget {
	final Database database;
	final int noteID;
	final String title;
	final String content;
	final int version;
  // widget parameters in constructor received from 'notes_list.dart'
	const EditNoteWidget({Key? key, required this.noteID, required this.title, required this.content, required this.version, required this.database}) : super(key: key);

  @override
  State<EditNoteWidget> createState() => EditNote();
}

class EditNote extends State<EditNoteWidget> {
	final TextEditingController titleController = TextEditingController();
	final TextEditingController contentController = TextEditingController(); // track inputs

  @override
  void initState() {
    super.initState();
		titleController.text = widget.title;
		contentController.text = widget.content; // 'widget[dot]' notation to access values reeived in constructor as default values
  }
  
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
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      GestureDetector( // to make image clickable
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute( builder: (context) => MyApp(database: widget.database)),
                        ),
                        child:  SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                            'assets/images/back.png',
                            fit: BoxFit.cover, // image scaling
                        ),
                      ),
                      ),
                    ],
                  )
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 34, vertical: 17),
                                actionsPadding: const EdgeInsets.symmetric(horizontal: 34, vertical: 17),
                                content: const Text('Are you sure you want to delete the note?', textAlign: TextAlign.center),
                                actions: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async{
                                          try {
                                            var note = Note(
                                              title: titleController.text,
                                              content: contentController.text,
                                              syncStatus: 'unsynced',
                                              isDeleted: 1, 
                                              version: widget.version
                                            );
                                            if(note.title != '' && note.content != '') {
                                              await deleteNote(note, widget.noteID);
                                              // ignore: use_build_context_synchronously
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute( builder: (context) => MyApp(database: widget.database)),
                                              );
                                            }
                                          } catch(e) {
                                            if (kDebugMode) {
                                              print('Error: $e');
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
                                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Handle cancel logic here
                                          Navigator.pop(context, 'Cancel');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(48, 190, 113, 1),
                                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ),

                                ],
                              );
                            },
                          );
                        },
                        child: Image.asset(
                          'assets/images/delete.png',
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async{
                          try {
                            var note = Note(
                              title: titleController.text,
                              content: contentController.text,
                              syncStatus: 'unsynced',
                              isDeleted: 0, 
                              version: widget.version + 1
                            );
                            if(note.title != '' && note.content != '') {
                              await updateNote(note, widget.noteID); // from database helper
                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                context,
                                MaterialPageRoute( builder: (context) => MyApp(database: widget.database)),
                              );
                            }
                          } catch(e) {
                            if (kDebugMode) {
                              print('Error: $e');
                            }
                          }
                        },
                        child:  Image.asset(
                          'assets/images/save.png',
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ],
                  )
                )
              ],
            ),
          ),
		
          Container(
                  margin: const EdgeInsets.only(top: 70),
                  child:  Column(
                    children: [
                      Card(
                        elevation: 0,
                        child: TextFormField(
                          controller: titleController, // defaults to widget[dot]title
                          style: const TextStyle(
                            fontSize: 18,
                          fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            
                          ),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        child: TextFormField( controller: contentController,
                          maxLines: null, // multi-line input
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
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

void main() {
  runApp(MaterialApp(
    home: Scaffold( backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notes List'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int noteID = 0;
          String title = '';
          String content = '';
          int version = 0;
          // ignore: prefer_typing_uninitialized_variables
          var database ;
          return SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: EditNoteWidget(noteID: noteID, title: title, content: content, version: version, database: database),
            )
          );
        }
      ),
    ),
  ));
}
