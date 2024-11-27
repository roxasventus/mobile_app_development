import 'dart:async';

import 'package:appproject/SideMenu.dart';
import 'package:flutter/material.dart';
import 'TaskManager.dart';
import 'Task.dart';

class AddPage extends StatefulWidget {
  final DateTime selectedDay;

  const AddPage({super.key, required this.selectedDay});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TaskManager _taskManager = TaskManager();
  late DateTime _date;
  final _formKey = GlobalKey<FormState>();
  String _taskName = "";
  late Stream<List<Task>> _taskStream;
  late Stream<List<Task>> _incompleteTaskStream;
  late StreamSubscription<List<Task>> _taskStreamSubscription;
  late StreamSubscription<List<Task>> _incompleteTaskStreamSubscription;

  List<Task> _tasks = [];
  List<Task> _incompleteTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDay;

    // Initialize streams
    _taskStream = _taskManager.fetchTaskListStream();
    _incompleteTaskStream = _taskManager.fetchIncompleteTasksStream();

    // Listen to task stream
    _taskStreamSubscription = _taskStream.listen((taskList) {
      setState(() {
        _tasks = taskList;
        _isLoading = false;
      });
    });

    // Listen to incomplete task stream
    _incompleteTaskStreamSubscription = _incompleteTaskStream.listen((taskList) {
      setState(() {
        _incompleteTasks = taskList;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    // Cancel the subscriptions
    _taskStreamSubscription.cancel();
    _incompleteTaskStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is DateTime) {
      _date = arguments;
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("할 일 추가"),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: '할 일'),
              Tab(text: '미완성'),
              Tab(text: '과거기록'),
            ],
          ),
        ),
        drawer: SideMenu(),
        body: TabBarView(
          children: [
            ///할일///////
            Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  '내가 저장한 할 일',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Task Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a task name.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _taskName = value ?? "";
                          },
                          initialValue: _taskName,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        child: Container(
                          width: 80,
                          height: 50,
                          color: Colors.deepPurple,
                          alignment: Alignment.center,
                          child: const Text(
                            '+',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            try {
                              final userName = await _taskManager.currentUserName;
                              await _taskManager.addToTaskList(_taskName, userName);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Task added successfully!')),
                              );

                              setState(() {
                                _taskName = "";
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to add task: $e')),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 2,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ReorderableListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Dismissible(
                        key: ValueKey('${task.id}-${task.title}'),
                        onDismissed: (direction) async {
                          try {
                            await _taskManager.deleteTask(task.title);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Task "${task.title}" deleted.')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete task: $e')),
                            );
                          }
                        },
                        child: ListTile(
                          title: Text(task.title),
                          leading: const Icon(Icons.task),
                          trailing: const Icon(Icons.navigate_next),
                          onTap: () async {
                            try {
                              final userName = await _taskManager.currentUserName;
                              final newTask = Task(
                                title: task.title,
                                date: widget.selectedDay,
                                userName: userName,
                              );

                              await _taskManager.addTask(newTask);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Task "${task.title}" added to ${widget.selectedDay.toLocal()}!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to add task: $e')),
                              );
                            }
                          },
                        ),
                      );
                    },
                    onReorder: (int oldIndex, int newIndex) async {
                      if (oldIndex < newIndex) newIndex -= 1;

                      final reorderedTasks = List.of(_tasks);
                      final item = reorderedTasks.removeAt(oldIndex);
                      reorderedTasks.insert(newIndex, item);

                      setState(() {
                        // reorderedTasks를 사용하여 UI를 업데이트
                      });
                    },
                  ),
                ),
              ],
            ),
            ///미완성////
            Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  '미완성 할 일',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 2,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ReorderableListView(
                    onReorder: (oldIndex, newIndex) async {
                      if (oldIndex < newIndex) newIndex -= 1;

                      final reorderedTasks = List.of(_incompleteTasks);
                      final item = reorderedTasks.removeAt(oldIndex);
                      reorderedTasks.insert(newIndex, item);

                      setState(() {
                        // Update the task list with new order
                        _incompleteTasks = reorderedTasks;
                      });

                      // You can also save the new order to Firebase here
                    },
                    children: _incompleteTasks.map((task) {
                      return Dismissible(
                        key: ValueKey('${task.id}-${task.title}'),
                        onDismissed: (direction) async {
                          try {
                            await _taskManager.deleteTask(task.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Task "${task.title}" deleted.')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete task: $e')),
                            );
                          }
                        },
                        child: ListTile(
                          title: Text(task.title),
                          leading: const Icon(Icons.task),
                          trailing: const Icon(Icons.navigate_next),
                          onTap: () async {
                            try {
                              final userName = await _taskManager.currentUserName;
                              final newTask = Task(
                                title: task.title,
                                date: widget.selectedDay,
                                userName: userName,
                              );

                              await _taskManager.addTask(newTask);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Task "${task.title}" added to ${widget.selectedDay.toLocal()}!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to add task: $e')),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),


            const Center(child: Text('과거기록')),
          ],
        ),
      ),
    );
  }
}
