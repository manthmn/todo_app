import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/repository/todo_repository.dart';

part 'todo_event.dart';
part 'todo_state.dart';

/// Bloc to manage Todo events and states.
/// It handles loading, adding, updating, and deleting todos.
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _todoRepository;

  TodoBloc(this._todoRepository) : super(TodoLoading()) {
    /// Emits a loading state, then attempts to fetch todos from the repository.
    on<LoadTodo>((event, emit) async {
      emit(TodoLoading());
      try {
        final todos = await _todoRepository.getTodos(
            query: event.query != '' ? event.query : null,
            index: event.index == 2
                ? 1
                : event.index == 1
                    ? 0
                    : null);
        emit(TodoLoaded(todos: todos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    });

    /// Emits a loading state, then adds a new todo to the repository.
    on<AddTodo>((event, emit) async {
      emit(TodoLoading());
      try {
        await _todoRepository.createTodo(event.todo);
        final todos = await _todoRepository.getTodos();
        emit(TodoLoaded(todos: todos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    });

    /// Emits a loading state, then deletes the specified todo from the repository.
    on<DeleteTodo>((event, emit) async {
      emit(TodoLoading());
      try {
        await _todoRepository.deleteTodo(event.todo.id!);
        final todos = await _todoRepository.getTodos();
        emit(TodoLoaded(todos: todos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    });

    /// Emits a loading state, then updates the specified todo in the repository.
    on<UpdateTodo>((event, emit) async {
      emit(TodoLoading());
      try {
        await _todoRepository.updateTodo(event.todo);
        final todos = await _todoRepository.getTodos();
        emit(TodoLoaded(todos: todos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    });
  }
}
