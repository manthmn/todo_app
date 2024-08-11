import 'package:todo_app/database/database.dart';
import 'package:todo_app/model/todo.dart';

class TodoRepository {
  final dbProvider = DatabaseProvider.dbProvider;

  //Adds new Todo records
  Future<int> createTodo(Todo todo) async {
    final db = await dbProvider.database;
    var result = db.insert(todoTABLE, todo.toDatabaseJson());
    return result;
  }

  //Get All Todo items
  //Searches if query string was passed
  Future<List<Todo>> getTodos({List<String>? columns, String? query, int? index}) async {
    try {
      final db = await dbProvider.database;
      List<Map<String, dynamic>>? result;

      // Initialize the where clause and where arguments list
      String whereClause = '';
      List<dynamic> whereArgs = [];

      // Add the query condition if it's not null and not empty
      if (query != null && query.isNotEmpty) {
        whereClause = 'description LIKE ?';
        whereArgs.add("%$query%");
      }

      // Add the isDone condition if it's not null
      if (index != null) {
        if (whereClause.isNotEmpty) {
          whereClause += ' AND ';
        }
        whereClause += 'is_done = ?';
        whereArgs.add(index);
      }

      // Perform the query based on the conditions
      if (whereClause.isNotEmpty) {
        result = await db.query(todoTABLE, columns: columns, where: whereClause, whereArgs: whereArgs);
      } else {
        result = await db.query(todoTABLE, columns: columns);
      }

      List<Todo> todo = result.isNotEmpty ? result.map((item) => Todo.fromDatabaseJson(item)).toList() : [];
      return todo;
    } catch (e) {
      return [];
    }
  }

  //Update Todo record
  Future<int> updateTodo(Todo todo) async {
    final db = await dbProvider.database;
    var result = await db.update(todoTABLE, todo.toDatabaseJson(), where: "id = ?", whereArgs: [todo.id]);
    return result;
  }

  //Delete Todo records
  Future<int> deleteTodo(int id) async {
    final db = await dbProvider.database;
    var result = await db.delete(todoTABLE, where: 'id = ?', whereArgs: [id]);

    return result;
  }

  //We are not going to use this in the demo
  Future deleteAllTodo() async {
    final db = await dbProvider.database;
    var result = await db.delete(
      todoTABLE,
    );

    return result;
  }
}
