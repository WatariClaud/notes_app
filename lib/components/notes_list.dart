// module imports
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

// component imports
import 'package:notes/components/edit_note.dart';
import 'package:notes/models/database_helper.dart';
import 'rich_text.dart';

// Widget to show list of notes
class NotesListWidget extends StatefulWidget {
	final Database database;
  const NotesListWidget({Key? key, required this.database}) : super(key: key); // set constructor with required database instance for main app

  @override
  State<NotesListWidget> createState() => NotesList();
}

class NotesList extends State<NotesListWidget> {
	late String apiUrl ='https://notesbackend-production-41fe.up.railway.app'; // backend url for nodejs/ mongodb server
	late int noteID; // late variables for future use in async functions
	late int noteVersion;
	List<Map<String, dynamic>> notes = [];

  // state management variables
	bool fetching = true;
	bool netErr = false;
  bool versionError = false;
  bool syncLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData(); // start app with fetching data from database (defined below)
  }

  Future<void> fetchData() async {
    try {
      await fetchNotesFromDatabase(); // Call the local database function
      final response = await http.get(Uri.parse('$apiUrl/read_notes')); // send http get to check connection and update state
      if (response.statusCode == 200) {
        setState(() {
          netErr = false;
          fetching = false;
        }); // stop fetching and confirmed network
      } else {
        throw Exception('Failed to sync data');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      setState(() {
        netErr = true;
        fetching = false;
      }); // stop fetching and no network
    }
  }
  Future<void> fetchNotesFromDatabase() async {
    try {
      final db = widget.database; // database passed in constructor and also from main app
      // Query data from the database
      List<Map<String, dynamic>> dataList = await db.query('notes', orderBy: 'noteID DESC', where: 'isDeleted = ?', whereArgs: [0],); // all valid notes
      List<Map<String, dynamic>> deletedList = await db.query('notes', orderBy: 'noteID DESC', where: 'isDeleted = ?', whereArgs: [1],); // all deleted notes
      setState(() {
        notes = dataList;
        fetching = false;
        versionError = false;
      }); // stop fetching, set notes list and no note version error
      if(!netErr && deletedList.isNotEmpty) {
        for (var item in deletedList) {
          await syncDeleteToServer(item['noteID']); // send deleted notes to server if connection confirmed (defined below)
        }
      }
    } catch(e) {
      setState(() {
        fetching = false;
      });
    }
  }
  Future<void> syncDeleteToServer(noteID) async {
    try {
      final response = await http.patch(Uri.parse('$apiUrl/delete_note/$noteID')); // backend endpoint to sync
      if (response.statusCode == 200) {

      } else {
        throw Exception('Failed to sync data');
      }
    } catch(e) {
      setState(() {
        netErr = true;
      });
    }
  }

  Widget buildAlertDialogContent(noteTitle) { // reusable widget component for the dialog box content
    if (versionError) {
      // alert user with incompatible server version - need to upgrade local version first
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          CustomRichText(
            noteTitle: noteTitle,
            firstText: 'The version for ',
            lastText: ' in the server is incompatible with your local version. Try upgrading locally first!',
          ),
        ],
      );
    } else {
      // alert user to confirm sync action
      return CustomRichText(
        noteTitle: noteTitle,
        firstText: 'Your local note ',
        lastText: ' has changes that conflict with the version on the server. Before syncing, we need you to decide how to resolve this.',
        optionalText: "\n\nIt's important to choose carefully to ensure you don't lose any critical information.",
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 75),
      height: MediaQuery.of(context).size.height - 110,  // minimize notes list height for scrollable viewport
		  child: ListView(
        shrinkWrap: true, // make area scrollable
        children: [
          if (notes.isEmpty && fetching) // empty (as initialized) list and sending reqest to local db yet
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
	            child: const Text('Fetching your notes')
            )
          else if (notes.isEmpty && !fetching) // done fetching but still empty list
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
	            child: const Text('Add a note')
            )
          else for (var item in notes) // iterate over list of notes
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0), 
                color: const Color.fromRGBO(253, 255, 182, 1),
              ),
              child: ListTile(
                // click title, open edit view (use params for faster access than more db queries in edit widget)
                leading: GestureDetector(
                  child: Text(item['title']),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditNoteWidget(
                      noteID: item['noteID'],
                      title: item['title'],
                      content: item['content'],
                      version: item['version'],
                      database: widget.database,
                    ),
                  ),
                ),
              ),
                trailing: GestureDetector(
                  // open prompt to sync when cloud icon clicked
                  onTap: () {
                    // not used imported method (callback in view) - works seamslessly inside callback to update parent state
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder( // to update state inside the alert box for content auto-update
                          builder: (context, setState) {
                            return AlertDialog(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 34, vertical: 17),
                              actionsPadding: const EdgeInsets.symmetric(horizontal: 34, vertical: 17),
                              content: netErr ? const Text('You are offline or server access is restricted') : buildAlertDialogContent(item['title']), // dynamic content based on state after check network
                              actions: <Widget>[
                                versionError ?  // note version has error, show single button
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'Exit'); // go back to previous widget
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
                                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                    ),
                                    child: const Text('Close'),
                                  ) :
                                  // else show two buttoons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    netErr ? Text('') : ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'Exit');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
                                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                      ),
                                      child: const Text('Local'),
                                    ),
                                    netErr ?
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context, 'Close');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(48, 190, 113, 1),
                                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                        ),
                                        child: const Text('Close', style: TextStyle(fontSize: 16)),
                                      )
                                    : ElevatedButton(
                                        onPressed: () async{
                                          try {
                                            noteID = item['noteID'];
                                            noteVersion = item['version']; // assign 'late' variables defined above
                                            setState(() {
                                              syncLoading = true; // Set syncLoading to true before the async operation to render loading icon
                                            });
                                            final Map<String, dynamic> syncRequestBody = {
                                              'title': item['title'],
                                              'content': item['content'],
                                            };
                                            final Map<String, dynamic> createRequestBody = {
                                              'title': item['title'],
                                              'content': item['content'],
                                              'noteID': noteID,
                                            };  // need json format for object to server. TODO: modular object
                                            final response = await http.patch(
                                              Uri.parse('$apiUrl/sync_note/$noteID?version=$noteVersion'),
                                                headers: <String, String>{
                                                'Content-Type': 'application/json; charset=UTF-8',
                                                },
                                              body: jsonEncode(syncRequestBody),
                                            ); // send sync to server
                                            if (response.statusCode == 200) {
                                              final Map<String, dynamic> responseBody = json.decode(response.body);
                                              final Map<String, dynamic> data = responseBody['data'];
                                              // check response has what props and update state or additional activity
                                              if (data['error'] != null && data['data']['database_error'] != null) {
                                                setState(() {
                                                  versionError = true; // Set to true to display error content
                                                });
                                              }
                                              // if server responded with empty, meaning no noteID, create the note on server
                                              if (data['error'] != null && data['data']['empty'] != null) {
                                                await http.post(Uri.parse('$apiUrl/create'), headers: <String, String>{
                                                  'Content-Type': 'application/json; charset=UTF-8',
                                                },
                                                body: jsonEncode(createRequestBody));
                                                await syncNote(noteID); // accept sync since new note
                                              }

                                              if (data['success'] != null) {
                                                  await syncNote(noteID); // update local storage with synced success
                                              }
                                              setState(() {
                                                syncLoading = false;
                                              });
                                            } else {
                                              setState(() {
                                                syncLoading = false;
                                              }); // updating state in individual conditional blocks here instead of outside blocks because of async operation
                                              throw Exception('Failed to sync note');
                                            }
                                          } catch (error) {
                                             if (kDebugMode) {
                                              print('Error: $error');
                                              setState(() {
                                                syncLoading = false;
                                              }); 
                                            }
                                          }
                                        if (!versionError && !syncLoading) {
                                          // ignore: use_build_context_synchronously
                                          Navigator.pop(context, 'Sync');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(48, 190, 113, 1),
                                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                      ),
                                      child: syncLoading ? const SizedBox(
                                        width: 20,
                                        height: 20, // reduce dimensions of loader becase default is bigger than partner button
                                        child: CircularProgressIndicator(),
                                      ) :
                                      const Text('Sync'), // Show a loader when isLoading is true 
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ).then((_) => setState(() {
                    notes = [];
                    fetchData(); // Update the widget or its state to reflect the new data by recalling the fetchData function on empty list (will rerender in n < 1second)
                  }));
                },
                child: Image.asset(
                  item['syncStatus'] == 'synced' ? 'assets/images/synced.png' : 'assets/images/unsynced.png', // ternary operator to show correct icon
                  fit: BoxFit.cover,
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ), const SizedBox(height: 90) // to give bottom spacer afte last item, so the sync icon is not hidden by the floating button
        ],
      )
    );
  }
}

void main() {
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
            scrollDirection: Axis.vertical, // make list scrollable
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: NotesListWidget(database: database),
            )
          );
        }
      ),
    ),
  ));
}