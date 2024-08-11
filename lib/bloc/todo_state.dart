part of 'todo_bloc.dart';

/// Abstract base class for all Todo states.
/// Extends Equatable to allow for state comparison.
abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

/// State indicating that todos are currently being loaded.
class TodoLoading extends TodoState {}

/// State indicating that todos have been successfully loaded.
class TodoLoaded extends TodoState {
  final List<Todo> todos;

  const TodoLoaded({this.todos = const <Todo>[]});

  @override
  List<Object> get props => [todos];
}

/// State indicating an error occurred while loading todos.
class TodoError extends TodoState {
  final String? message;

  const TodoError(this.message);

  @override
  List<Object?> get props => [message];
}
