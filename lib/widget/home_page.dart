import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/constant/constant.dart';
import 'package:todo_app/model/todo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TodoBloc _todoBloc;
  int _selectedIndex = 0;
  final TextEditingController _searchCtlr = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the TodoBloc from the context
    _todoBloc = BlocProvider.of<TodoBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    _searchCtlr.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: ColorConstants.primary,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: ColorConstants.primary,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          // Unfocus any text fields when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: _appBar(),
          extendBodyBehindAppBar: false,
          resizeToAvoidBottomInset: true,
          backgroundColor: ColorConstants.primary,
          body: Container(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                _getToggleButton(),
                const SizedBox(height: 8),
                Expanded(child: Container(child: _buildTodoPage())),
              ],
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: FloatingActionButton(
              elevation: 5.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onPressed: () {
                // Show the dialog to add a new Todo
                _showAddTodoBox(context, null);
              },
              backgroundColor: ColorConstants.primaryLight,
              child: const Icon(Icons.add, size: 32, color: ColorConstants.textColor),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSize _appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(76),
      child: AppBar(
        backgroundColor: ColorConstants.primary,
        flexibleSpace: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Text(
                'ToDo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ColorConstants.textColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchCtlr,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: ColorConstants.textColor),
                    suffixIcon: IconButton(
                      splashRadius: 24,
                      icon: Icon(_searchCtlr.text == '' ? Icons.search : Icons.close, color: ColorConstants.textColor),
                      onPressed: () {
                        if (_searchCtlr.text != '') {
                          setState(() {
                            _searchCtlr.clear();
                          });
                          _todoBloc.add(const LoadTodo(query: ''));
                        }
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    filled: true,
                    fillColor: ColorConstants.primaryLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: ColorConstants.textColor),
                  onChanged: (query) {
                    setState(() {
                      _searchCtlr.text;
                    });
                    _todoBloc.add(LoadTodo(index: _selectedIndex, query: query));
                  },
                ),
              ),
            ],
          ),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _getToggleButton() {
    return Container(
      alignment: Alignment.center,
      height: 40,
      width: double.infinity,
      child: ToggleButtons(
        isSelected: [0 == _selectedIndex, 1 == _selectedIndex, 2 == _selectedIndex],
        onPressed: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          _todoBloc.add(LoadTodo(index: index, query: _searchCtlr.text));
        },
        borderRadius: BorderRadius.circular(20.0),
        selectedColor: ColorConstants.textColor,
        fillColor: ColorConstants.primaryLight,
        color: ColorConstants.textColor,
        borderColor: ColorConstants.primaryLight,
        selectedBorderColor: ColorConstants.primaryLight,
        children: const <Widget>[
          Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('All')),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Pending')),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Completed')),
        ],
      ),
    );
  }

  Widget _buildTodoPage() {
    return BlocBuilder<TodoBloc, TodoState>(builder: (context, state) {
      if (state is TodoLoaded) {
        return state.todos.isEmpty && _selectedIndex != 2
            ? _todoMessageWidget(Icons.format_list_bulleted_add, 'Start adding Todo...')
            : _getTodoList(state.todos);
      } else if (state is TodoLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is TodoError) {
        return _todoMessageWidget(Icons.error_outline, 'Something went wrong!');
      } else {
        return _todoMessageWidget(Icons.format_list_bulleted_add, 'Start adding Todo...');
      }
    });
  }

  Widget _getTodoList(List<dynamic> data) {
    return ListView.builder(
      key: const Key("listview_builder"),
      itemCount: data.length,
      itemBuilder: (context, itemPosition) {
        Todo todo = data[itemPosition];
        return Slidable(
          key: ObjectKey(todo),
          startActionPane: ActionPane(
            extentRatio: 0.2,
            motion: const ScrollMotion(),
            children: [
              InkWell(
                onTap: () {
                  _todoBloc.add(DeleteTodo(todo: todo));
                },
                child: Container(
                  width: 76,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: const BoxDecoration(
                    color: ColorConstants.textColor,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.delete, size: 20),
                      Text("Delete", style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: ColorConstants.textColor, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            color: ColorConstants.primary,
            child: InkWell(
              onTap: () {
                _showAddTodoBox(context, todo);
              },
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: Text(
                      todo.description!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 12,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontFamily: 'RobotoMono',
                        color: ColorConstants.textColor,
                        decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: InkWell(
                      onTap: () {
                        // Toggle the completion status of the todo
                        todo.isDone = !todo.isDone;
                        _todoBloc.add(UpdateTodo(todo: todo));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: todo.isDone
                            ? const Icon(Icons.done, size: 24, color: ColorConstants.textColor)
                            : const Icon(Icons.check_box_outline_blank, size: 24, color: ColorConstants.textColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _todoMessageWidget(IconData iconData, String message) {
    return Column(
      children: [
        const SizedBox(height: 200),
        Icon(iconData, size: 70, color: ColorConstants.textColor),
        const SizedBox(height: 20),
        Text(
          message,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: ColorConstants.textColor),
        ),
      ],
    );
  }

  void _showAddTodoBox(BuildContext context, Todo? todo) {
    final todoController = TextEditingController(text: todo?.description);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: ColorConstants.primary,
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${todo != null ? 'Update your' : 'Create new'} Todo',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorConstants.textColor),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorConstants.textColor, width: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      // color: ColorConstants.textColor,
                    ),
                    alignment: Alignment.center,
                    child: TextFormField(
                      controller: todoController,
                      textInputAction: TextInputAction.newline,
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      autofocus: true,
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Empty description!';
                        }
                        return value.contains('') ? 'Do not use the @ char.' : null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter your todo',
                        hintStyle: TextStyle(color: ColorConstants.textColor, fontSize: 14.5),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      style: const TextStyle(color: ColorConstants.textColor, fontSize: 14.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.secondary),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel', style: TextStyle(color: ColorConstants.textColor)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          final Todo newTodo;
                          if (todo != null) {
                            todo.description = todoController.text;
                            newTodo = todo;
                          } else {
                            newTodo = Todo(description: todoController.text);
                          }
                          if (newTodo.description!.isNotEmpty) {
                            _todoBloc.add(todo != null ? UpdateTodo(todo: newTodo) : AddTodo(todo: newTodo));
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          todo != null ? 'Update' : 'Save',
                          style: const TextStyle(color: ColorConstants.textColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
