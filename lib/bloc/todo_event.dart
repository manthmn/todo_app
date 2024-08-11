part of 'todo_bloc.dart';

/// Abstract base class for all Todo events.
/// Extends Equatable to allow for event comparison.
abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load todos, optionally with a search query or status index.
class LoadTodo extends TodoEvent {
  final String? query;
  final int? index;

  const LoadTodo({this.query = "", this.index});

  @override
  List<Object?> get props => [query, index];
}

/// Event to add a new todo item.
class AddTodo extends TodoEvent {
  final Todo todo;

  const AddTodo({required this.todo});

  @override
  List<Object> get props => [todo];
}

/// Event to update an existing todo item.
class UpdateTodo extends TodoEvent {
  final Todo todo;

  const UpdateTodo({required this.todo});

  @override
  List<Object> get props => [todo];
}

/// Event to delete a specific todo item.
class DeleteTodo extends TodoEvent {
  final Todo todo;

  const DeleteTodo({required this.todo});

  @override
  List<Object> get props => [todo];
}
