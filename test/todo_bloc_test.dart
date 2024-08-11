import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/repository/todo_repository.dart';

// Mock class for TodoRepository
class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late TodoBloc todoBloc;
  late MockTodoRepository mockTodoRepository;

  // Setup for each test
  setUp(() {
    mockTodoRepository = MockTodoRepository();
    todoBloc = TodoBloc(mockTodoRepository);
  });

  tearDown(() {
    todoBloc.close();
  });

  group('TodoBloc', () {
    final todo = Todo(
      id: 1,
      description: 'Test Todo',
      isDone: false,
    );

    final updatedTodo = Todo(
      id: 1,
      description: 'Test Todo',
      isDone: true,
    );

    // Test to check the initial state of the TodoBloc
    test('initial state is TodoLoading', () {
      expect(todoBloc.state, TodoLoading());
    });

    // Test for LoadTodo event
    blocTest<TodoBloc, TodoState>(
      'emits [TodoLoaded] when LoadTodo is added',
      build: () {
        when(() => mockTodoRepository.getTodos()).thenAnswer((_) async => [todo]);
        return todoBloc;
      },
      skip: 1,
      act: (bloc) => bloc.add(const LoadTodo()),
      expect: () => [
        TodoLoaded(todos: [todo]),
      ],
    );

    // Test for AddTodo event
    blocTest<TodoBloc, TodoState>(
      'emits [TodoLoaded] when AddTodo is added',
      build: () {
        when(() => mockTodoRepository.createTodo(todo)).thenAnswer((_) async => todo.id!);
        when(() => mockTodoRepository.getTodos()).thenAnswer((_) async => [todo]);
        return todoBloc;
      },
      skip: 1,
      act: (bloc) => bloc.add(AddTodo(todo: todo)),
      expect: () => [
        TodoLoaded(todos: [todo]),
      ],
    );

    // Test for UpdateTodo event
    blocTest<TodoBloc, TodoState>(
      'emits [TodoLoaded] when UpdateTodo is added',
      build: () {
        when(() => mockTodoRepository.updateTodo(updatedTodo))
            .thenAnswer((_) async => 1); // Return 1 for a successful update
        when(() => mockTodoRepository.getTodos()).thenAnswer((_) async => [updatedTodo]);
        return todoBloc;
      },
      skip: 1,
      act: (bloc) => bloc.add(UpdateTodo(todo: updatedTodo)),
      expect: () => [
        TodoLoaded(todos: [updatedTodo]),
      ],
    );

    // Test for DeleteTodo event
    blocTest<TodoBloc, TodoState>(
      'emits [TodoLoaded] when DeleteTodo is added',
      build: () {
        when(() => mockTodoRepository.deleteTodo(todo.id!))
            .thenAnswer((_) async => 1); // Return 1 for successful deletion
        when(() => mockTodoRepository.getTodos()).thenAnswer((_) async => []);
        return todoBloc;
      },
      skip: 1,
      act: (bloc) => bloc.add(DeleteTodo(todo: todo)),
      expect: () => [
        const TodoLoaded(todos: []),
      ],
    );

    // Test for error handling in repository
    blocTest<TodoBloc, TodoState>(
      'emits [TodoError] when repository throws an exception',
      build: () {
        when(() => mockTodoRepository.getTodos()).thenThrow(Exception('Error loading todos'));
        return todoBloc;
      },
      skip: 1,
      act: (bloc) => bloc.add(const LoadTodo()),
      expect: () => [
        TodoError(Exception('Error loading todos').toString()),
      ],
    );
  });
}
