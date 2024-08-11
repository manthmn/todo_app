part of 'todo_bloc.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object> get props => [];
}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;

  const TodoLoaded({this.todos = const <Todo>[]});

  @override
  List<Object> get props => [todos];
}

class TodoError extends TodoState {
  final String? message;
  const TodoError(this.message);
}
