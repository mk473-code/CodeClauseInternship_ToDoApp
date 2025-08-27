import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App with CRUD',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoHomePage(),
    );
  }
}

class Task {
  String title;
  String category;
  bool isDone;

  Task({required this.title, required this.category, this.isDone = false});

  Map<String, dynamic> toJson() {
    return {"title": title, "category": category, "isDone": isDone};
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json["title"],
      category: json["category"],
      isDone: json["isDone"],
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  List<Task> tasks = [];
  String filterCategory = 'All';

  final Map<String, String> categorySymbols = {
    'All': '📋 All',
    'Work': '💼 Work',
    'Study': '📚 Study',
    'Personal': '❤️ Personal',
    'Health': '🏃 Health',
    'Ideas': '💡 Ideas',
  };

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString("tasks");
    if (tasksJson != null) {
      List decoded = jsonDecode(tasksJson);
      setState(() {
        tasks = decoded.map((e) => Task.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List jsonList = tasks.map((e) => e.toJson()).toList();
    await prefs.setString("tasks", jsonEncode(jsonList));
  }

  void _taskDialog({Task? task, int? index}) {
    TextEditingController taskController =
        TextEditingController(text: task?.title ?? "");
    String selectedCategory = task?.category ?? 'Work';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task == null ? "➕ Create Task" : "✏️ Update Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: const InputDecoration(labelText: "Task Title"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                items: categorySymbols.keys
                    .where((c) => c != 'All')
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(categorySymbols[cat]!),
                        ))
                    .toList(),
                onChanged: (val) {
                  selectedCategory = val!;
                },
                decoration: const InputDecoration(labelText: "Category"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text(task == null ? "Create" : "Update"),
              onPressed: () {
                setState(() {
                  if (task == null) {
                    tasks.add(Task(
                      title: taskController.text,
                      category: selectedCategory,
                    ));
                  } else {
                    tasks[index!] = Task(
                      title: taskController.text,
                      category: selectedCategory,
                      isDone: task.isDone,
                    );
                  }
                });
                _saveTasks();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = filterCategory == 'All'
        ? tasks
        : tasks.where((task) => task.category == filterCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("✅ Todo App with CRUD"),
        actions: [
          DropdownButton<String>(
            value: filterCategory,
            items: categorySymbols.keys
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(categorySymbols[cat]!),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                filterCategory = val!;
              });
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text("No tasks yet. ➕ Create one!"))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "👀 Read Tasks",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                              "Category: ${categorySymbols[task.category]}"),
                          leading: Checkbox(
                            value: task.isDone,
                            onChanged: (val) {
                              setState(() {
                                task.isDone = val!;
                              });
                              _saveTasks();
                            },
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blueAccent),
                                label: const Text("Update"),
                                onPressed: () {
                                  _taskDialog(
                                      task: task, index: tasks.indexOf(task));
                                },
                              ),
                              TextButton.icon(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                label: const Text("Delete"),
                                onPressed: () {
                                  _deleteTask(tasks.indexOf(task));
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _taskDialog(),
        icon: const Icon(Icons.add),
        label: const Text("Create Task"),
      ),
    );
  }
}
