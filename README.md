# **To-Do List Application(Android/iOS)**

This is a simple and efficient To-Do List application built with Flutter, utilizing the BLoC pattern for state management. The app allows users to add, update, delete, and filter to-do items. It also includes search functionality and persistent storage using SQLite.

## **Features**

- **Add, update, and delete to-do items**
- **Filter tasks by status**: All, Pending, or Completed
- **Search through your to-do list**
- **Mark tasks as complete or incomplete**
- **Persistent storage** with SQLite

## **Screenshots**
<div style="display: flex;">
<img src="https://github.com/user-attachments/assets/072bc44f-e74a-433f-a327-c5151f7c6641" width="240" height="500">
<img src="https://github.com/user-attachments/assets/8c87d5ff-e4ed-453c-a5ca-5375466de8ad" width="240" height="500">
<img src="https://github.com/user-attachments/assets/fd3ffcd3-34b6-4f48-b92d-4c79da55bfd6" width="240" height="500">
<img src="https://github.com/user-attachments/assets/024ea613-5876-4013-9597-843f7bfdbdc8" width="240" height="500">
</div>



## **Getting Started**

### **Prerequisites**

Before you begin, ensure you have Flutter installed on your machine. You can follow the [official installation guide](https://flutter.dev/docs/get-started/install) to set it up.

This is project is build upon flutter 3.7.3 and related dependencies.

### **Running the Application**

1. **Clone the Repository**

   ```bash
   git clone https://github.com/manthmn/todo_app.git
   cd todo_app

2. **Run the Application**
  
   ```bash
   #Choose your preferred method to run the application
   #Using Flutter CLI
   #Install the necessary dependencies
   flutter pub get
   flutter run

3. **Using the Application**

- **Add To-Do**: Press the '+' button to add a new to-do item.
- **Mark as Done**: Tap the checkbox next to a to-do item to mark it as completed.
- **Delete To-Do**: Swipe right on a to-do item to delete it.
- **Filter To-Dos**: Use the toggle buttons to filter between All, Pending, and Completed tasks.
- **Search To-Dos**: Use the search bar to filter tasks by name.

4. **Testing**

    This project includes unit and widget tests to ensure the application functions as expected. The tests cover:

    - BLoC state transitions(Unit Test cases).
    - Widget interactions.

    To run the tests:
     ```bash
     flutter test

5. **Project Structure**

  ```plaintext
  lib/
  │
  ├── bloc/
  │   └── todo_bloc.dart
  │   └── todo_event.dart
  │   └── todo_state.dart
  │
  ├── model/
  │   └── todo.dart
  │
  ├── repository/
  │   └── todo_repository.dart
  │
  └── widget/
      └── home_page.dart
```

**bloc/:** Contains the BLoC files (todo_bloc.dart, todo_event.dart, todo_state.dart) that manage the business logic and state of the application.

**model/:** Contains the Todo model class, which defines the structure of a to-do item.

**repository/:** Contains the TodoRepository class, which handles CRUD operations on to-do items using SQLite.

**widget/:** Contains the UI components, including home_page.dart.

  ```plaintext
  test/
  │
  └── home_page_test.dart
  └── todo_bloc_test.dart
```

**test/:** Unit and widget tests for the BLoC, widgets.
