// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/repository/todo_repository.dart';
import 'package:todo_app/widget/home_page.dart';

extension PumpUntilFound on WidgetTester {
  Future<void> pumpUntilFound(
    Finder finder, {
    Duration duration = const Duration(milliseconds: 100),
    int tries = 10,
  }) async {
    for (var i = 0; i < tries; i++) {
      await pump(duration);

      final result = finder.precache();

      if (result) {
        finder.evaluate();

        break;
      }
    }
  }
}

// Mock classes
class MockTodoBloc extends Mock implements TodoBloc {}

// Mock TodoRepository class
class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoBloc mockTodoBloc;

  setUp(() {
    mockTodoBloc = MockTodoBloc();
  });

  testWidgets('UI elements are present and correct or not', (WidgetTester tester) async {
    // when(mockTodoBloc.state).thenReturn(TodoLoading());

    await tester.runAsync(() async {
      await tester.pumpWidget(const MyApp());
    });

    // Tap the add icon button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(); // Perform one frame of animation
    await tester.pump(const Duration(milliseconds: 500));

    // Enter text and save
    await tester.enterText(find.byType(TextFormField), 'New Todo Item');
    final saveButton = find.byKey(const Key('save_button'));
    await tester.tap(saveButton);
    // await tester.runAsync(() async {

    //   for (int i = 0; i < 5; i++) {
    //     // because pumpAndSettle doesn't work with riverpod
    //     await tester.pump(Duration(seconds: 10));
    //   }
    // });

    // Find the ListView widget
    final listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    // Find all ListTile widgets inside the ListView
    final listTileFinder = find.byType(Dismissible);
    final listTileWidgets = tester.widgetList<Dismissible>(listTileFinder);

    // Check the length of the ListTile widgets
    expect(listTileWidgets.length, 5);

    while (listTileWidgets.length != 5) {
      await tester.pump();
    }

    // final finder = find.text('New Todo Item');

    // await tester.pumpUntilFound(finder);

    // expect(finder, findsOneWidget);
  });

  testWidgets('UI elements are present and correct', (WidgetTester tester) async {
    // when(mockTodoBloc.state).thenReturn(TodoLoading());

    await tester.pumpWidget(const MyApp());

    // Check for FloatingActionButton
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Check for BottomAppBar
    expect(find.byType(BottomAppBar), findsOneWidget);

    // Find the add icon button
    final addButton = find.byIcon(Icons.add);
    expect(addButton, findsOneWidget);

    // Tap the add icon button
    await tester.tap(addButton);
    await tester.pump(); // Perform one frame of animation
    await tester.pump(const Duration(milliseconds: 500));

    // Wait for the bottom sheet to open

    // Verify that the bottom sheet is open
    expect(find.byType(BottomSheet), findsOneWidget);

    // Verify the presence of TextFormField
    expect(find.byType(TextFormField), findsOneWidget);

    // Check for initial empty state message
    // expect(find.text('Start adding Todo...'), findsOneWidget);

    // Verify the bottom sheet is opened
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byIcon(Icons.save), findsOneWidget);

    // Enter text and save
    await tester.enterText(find.byType(TextFormField), 'New Todo Item');
    // Verify the entered text
    final textFieldWidget = tester.widget<TextFormField>(find.byType(TextFormField));
    final textEditingController = textFieldWidget.controller;
    expect(textEditingController?.text, 'New Todo Item', reason: 'TextFormField should contain the entered text');
    final saveButton = find.byKey(const Key('save_button'));
    await tester.tap(saveButton);

    await tester.pump(const Duration(seconds: 30));
    // expect(find.byType(BottomSheet), findsNothing, reason: 'BottomSheet should be closed');
    // await tester.pumpAndSettle();
    // await tester.tap(find.byType(IconButton));
    // await tester.pump();
  });

  testWidgets('Add Todo bottom sheet opens and adds todo', (WidgetTester tester) async {
    when(() => mockTodoBloc.state).thenReturn(TodoLoading());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TodoBloc>(
          create: (context) => mockTodoBloc,
          child: const HomePage(),
        ),
      ),
    );

    // Tap the FloatingActionButton to open bottom sheet
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Check if bottom sheet is opened
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byIcon(Icons.save), findsOneWidget);

    // Enter text and save todo
    await tester.enterText(find.byType(TextFormField), 'New Todo');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pump();

    // Verify that TodoBloc's add event was called
    verify(() => mockTodoBloc.add(AddTodo(todo: Todo(description: 'New Todo')))).called(1);
  });

  testWidgets('Search Todo bottom sheet opens and performs search', (WidgetTester tester) async {
    when(() => mockTodoBloc.state).thenReturn(TodoLoading());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TodoBloc>(
          create: (context) => mockTodoBloc,
          child: const HomePage(),
        ),
      ),
    );

    // Tap the search icon
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Check if search bottom sheet is opened
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Enter text and search
    await tester.enterText(find.byType(TextFormField), 'Search Todo');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    // Verify that TodoBloc's get event was called
    verify(() => mockTodoBloc.add(const LoadTodo(query: 'Search Todo'))).called(1);
  });

  testWidgets('Dismiss todo item triggers delete event', (WidgetTester tester) async {
    final List<Todo> todos = [
      Todo(description: 'Todo 1'),
      Todo(description: 'Todo 2'),
    ];

    when(() => mockTodoBloc.state).thenReturn(TodoLoaded(todos: todos));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TodoBloc>(
          create: (context) => mockTodoBloc,
          child: const HomePage(),
        ),
      ),
    );

    // Swipe to dismiss the first todo
    await tester.drag(find.text('Todo 1'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Verify that TodoBloc's delete event was called
    verify(() => mockTodoBloc.add(DeleteTodo(todo: todos[0]))).called(1);
  });
}
