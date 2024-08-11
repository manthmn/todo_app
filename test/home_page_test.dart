import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/repository/todo_repository.dart';
import 'package:todo_app/widget/home_page.dart';

// Global list to mock Todo data
List<Todo> globalTodos = [];

// Mock repository to simulate TodoRepository behavior
class MockTodoRepository extends Mock implements TodoRepository {
  @override
  Future<List<Todo>> getTodos({List<String>? columns, String? query, int? index}) async {
    return globalTodos;
  }

  @override
  Future<int> createTodo(Todo todo) async {
    todo.id ??= globalTodos.isEmpty ? 1 : globalTodos.last.id! + 1;
    globalTodos.add(todo);
    return todo.id!;
  }

  @override
  Future<int> updateTodo(Todo todo) async {
    int entryAffected = 0;
    globalTodos.map((t) {
      if (t.id == todo.id) {
        t.description = todo.description;
        t.isDone = todo.isDone;
        entryAffected = 1;
      }
    });
    return entryAffected;
  }

  @override
  Future<int> deleteTodo(int id) async {
    int entryAffected = 0;
    globalTodos.removeWhere((todo) {
      if (todo.id == id) {
        entryAffected = 1;
        return true;
      }
      return false;
    });
    return entryAffected;
  }
}

void main() {
  late TodoBloc todoBloc;
  late MockTodoRepository mockTodoRepository;

  // Set up the mock repository and bloc before each test
  setUp(() {
    globalTodos = []; // Clear globalTodos before each test
    mockTodoRepository = MockTodoRepository();
    todoBloc = TodoBloc(mockTodoRepository);
  });

  // Close the bloc after each test
  tearDown(() {
    todoBloc.close();
  });

  // Create a MaterialApp with the HomePage widget and mock repository
  Widget createHomePage() {
    return MaterialApp(
      home: RepositoryProvider(
        create: (context) => mockTodoRepository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => TodoBloc(RepositoryProvider.of<MockTodoRepository>(context))..add(const LoadTodo()),
            ),
          ],
          child: const HomePage(),
        ),
      ),
    );
  }

  group('HomePage', () {
    testWidgets('HomePage renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Verify if the AppBar title is present
      expect(find.text('ToDo'), findsOneWidget);

      // Verify if the FloatingActionButton is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Toggle buttons are present and functional', (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Verify if toggle buttons are present
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      // Tap on the 'Pending' toggle button and verify the state
      await tester.tap(find.text('Pending'));
      await tester.pump();

      // Verify if 'Pending' is selected by checking the UI state change
      expect(
          find.byWidgetPredicate((widget) => widget is ToggleButtons && widget.isSelected[1] == true), findsOneWidget);
    });

    testWidgets('Tapping FAB opens Add Todo dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Tap on the FloatingActionButton
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify if the dialog is displayed
      expect(find.text('Create new Todo'), findsOneWidget);

      // Verify if the input field is present in the dialog
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('Adding a new Todo updates the list', (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Tap on the FloatingActionButton to open the Add Todo dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Enter text in the Todo input field
      await tester.enterText(find.byType(TextFormField), 'New Todo 2');
      await tester.pump();

      // Tap on the 'Save' button to add the Todo
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify if the new Todo item appears in the list
      expect(find.text('New Todo 2'), findsOneWidget);
    });

    testWidgets('Search functionality filters the list', (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Add a Todo item to ensure there's something to search for
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'Searchable Todo');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Enter text in the search field
      await tester.enterText(find.byType(TextField), 'Searchable');
      await tester.pump();

      // Verify if the list contains the searched item
      expect(find.text('Searchable Todo'), findsOneWidget);

      // Clear the search field
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Verify if the list is restored after clearing the search
      expect(find.text('Searchable Todo'), findsOneWidget);
    });

    testWidgets('Marking a Todo as done updates the UI', (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Add a Todo item to the list
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'Markable Todo');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Tap the checkbox to mark the Todo as done
      await tester.tap(find.byIcon(Icons.check_box_outline_blank));
      await tester.pump();

      // Verify if the Todo item is marked as done (check for line-through decoration)
      expect(find.byWidgetPredicate(
        (widget) {
          return widget is Text &&
              widget.data == 'Markable Todo' &&
              widget.style!.decoration == TextDecoration.lineThrough;
        },
      ), findsOneWidget);
    });

    testWidgets('Deleting a new Todo from the list', (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Tap on the FloatingActionButton to open the Add Todo dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Enter text in the Todo input field
      await tester.enterText(find.byType(TextFormField), 'Delete Todo');
      await tester.pump();

      // Tap on the 'Save' button to add the Todo
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify if the new Todo item appears in the list
      expect(find.text('Delete Todo'), findsOneWidget);

      // Perform a drag from left to right to reveal delete option
      await tester.drag(find.text('Delete Todo'), const Offset(300, 100));
      await tester.pump();

      // Verify if the delete button appears
      final finder = find.byIcon(Icons.delete);
      expect(finder, findsOneWidget);

      // Tap the delete button to remove the Todo
      await tester.tap(finder);

      // Rebuild the widget after the drag
      await tester.pump();

      // Verify if the Todo item has been removed from the list
      expect(find.text('Delete Todo'), findsNothing);
    });
  });
}
