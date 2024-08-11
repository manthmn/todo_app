import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/repository/todo_repository.dart';
import 'package:todo_app/widget/home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo App',
      theme: ThemeData(primarySwatch: Colors.grey, canvasColor: Colors.transparent),
      home: RepositoryProvider(
        // Provides an instance of TodoRepository to the widget tree
        create: (context) => TodoRepository(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => TodoBloc(RepositoryProvider.of<TodoRepository>(context))..add(const LoadTodo()),
            )
          ],
          child: const HomePage(),
        ),
      ),
    );
  }
}
