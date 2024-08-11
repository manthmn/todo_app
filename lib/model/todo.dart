class Todo {
  int? id; // Unique identifier for the todo item
  String? description; // Description of the todo item
  bool isDone = false; // Status of the todo item, default is false

  Todo({this.id, this.description, this.isDone = false});

  // Factory constructor to create a Todo object from JSON
  factory Todo.fromDatabaseJson(Map<String, dynamic> data) => Todo(
        id: data['id'],
        description: data['description'],

        // Convert the is_done field from JSON to a boolean
        // SQLite uses 0 for false and 1 for true
        isDone: data['is_done'] == 0 ? false : true,
      );

  // Method to convert a Todo object to a JSON-like Map
  Map<String, dynamic> toDatabaseJson() => {
        "id": id,
        "description": description,

        // Convert the isDone status to an integer for storing in SQLite
        "is_done": isDone == false ? 0 : 1,
      };
}
