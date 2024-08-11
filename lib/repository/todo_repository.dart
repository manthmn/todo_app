import 'package:todo_app/database/database.dart';
import 'package:todo_app/model/todo.dart';

class TodoRepository {
  final dbProvider = DatabaseProvider.dbProvider; // instance of DatabaseProvider

  // Adds a new Todo record to the database
  Future<int> createTodo(Todo todo) async {
    final db = await dbProvider.database;
    var result = await db.insert(todoTABLE, todo.toDatabaseJson());
    return result;
  }

  // Get All Todo items
  // Filters by query string and index
  Future<List<Todo>> getTodos({List<String>? columns, String? query, int? index}) async {
    try {
      final db = await dbProvider.database;
      List<Map<String, dynamic>>? result;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      // Add a query condition if a query string is provided
      if (query != null && query.isNotEmpty) {
        whereClause = 'description LIKE ?';
        whereArgs.add("%$query%");
      }

      // Add a condition for the isDone field if an index is provided
      if (index != null) {
        if (whereClause.isNotEmpty) {
          whereClause += ' AND ';
        }
        whereClause += 'is_done = ?';
        whereArgs.add(index);
      }

      if (whereClause.isNotEmpty) {
        result = await db.query(todoTABLE, columns: columns, where: whereClause, whereArgs: whereArgs);
      } else {
        result = await db.query(todoTABLE, columns: columns);
      }

      List<Todo> todos = result.isNotEmpty ? result.map((item) => Todo.fromDatabaseJson(item)).toList() : [];
      return todos;
    } catch (e) {
      return [];
    }
  }

  // Update Todo record
  Future<int> updateTodo(Todo todo) async {
    final db = await dbProvider.database;
    var result = await db.update(todoTABLE, todo.toDatabaseJson(), where: "id = ?", whereArgs: [todo.id]);
    return result;
  }

  // Delete Todo records
  Future<int> deleteTodo(int id) async {
    final db = await dbProvider.database;
    var result = await db.delete(todoTABLE, where: 'id = ?', whereArgs: [id]);
    return result;
  }
}
