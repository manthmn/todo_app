class Todo {
  int? id;
  String? description;
  bool isDone = false;

  Todo({this.id, this.description, this.isDone = false});

  // Add the copyWith method
  Todo copyWith({
    int? id,
    String? description,
    bool? isDone,
  }) {
    return Todo(
      id: id ?? this.id,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
    );
  }

  factory Todo.fromDatabaseJson(Map<String, dynamic> data) => Todo(
        //Factory method will be used to convert JSON objects that
        //are coming from querying the database and converting
        //it into a Todo object

        id: data['id'],
        description: data['description'],

        //Since sqlite doesn't have boolean type for true/false,
        //we will use 0 to denote that it is false
        //and 1 for true
        isDone: data['is_done'] == 0 ? false : true,
      );

  Map<String, dynamic> toDatabaseJson() => {
        //A method will be used to convert Todo objects that
        //are to be stored into the datbase in a form of JSON

        "id": id,
        "description": description,
        "is_done": isDone == false ? 0 : 1,
      };
}
