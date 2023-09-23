// model to use for insert and edit

class Note {
  final String title;
  final String content;
  final String syncStatus;
  final int isDeleted;
  final int version;

  const Note({
    required this.title,
    required this.content,
    required this.syncStatus,
    required this.isDeleted,
    required this.version,
  }); // all mandatory fields

  // make valid json object
  Map<String, dynamic> toMap() { // for local db
    return {
      'title': title,
      'content': content,
      'syncStatus': syncStatus,
      'isDeleted': isDeleted,
      'version': version,
    };
  }

  Map<String, dynamic> toJson() { // for server
    return {
      'title': title,
      'content': content,
    };
  }
}
