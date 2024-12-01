// AddPage.dart
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
  late Stream<List<Task>> _pastTaskStream;
  late StreamSubscription<List<Task>> _taskStreamSubscription;
  late StreamSubscription<List<Task>> _incompleteTaskStreamSubscription;
  late StreamSubscription<List<Task>> _pastTaskStreamSubscription;

  List<Task> _tasks = [];
  List<Task> _incompleteTasks = [];
  List<Task> _pastTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDay;

    // Initialize streams
    _taskStream = _taskManager.fetchTaskListStream();
    _incompleteTaskStream = _taskManager.fetchIncompleteTasksStream();
    _pastTaskStream = _taskManager.fetchPastTasksStream();
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

    // Listen to past task stream
    _pastTaskStreamSubscription = _pastTaskStream.listen((taskList) {
      setState(() {
        _pastTasks = taskList;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    // Cancel the subscriptions
    _taskStreamSubscription.cancel();
    _incompleteTaskStreamSubscription.cancel();
    _pastTaskStreamSubscription.cancel();
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
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back), // 뒤로가기 버튼 아이콘
              onPressed: () {
                Navigator.pop(context); // 이전 화면으로 돌아가기
              },
            ),
          ],
        ),
        drawer: SideMenu(),
        body: TabBarView(
          children: [
            /// Task Tab
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
                _buildTaskForm(),
                const SizedBox(height: 10),
                Expanded(
                  flex: 2,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildTaskList(),
                ),
              ],
            ),

            /// Incomplete Task Tab
            Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  '미완성 할 일',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 2,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildIncompleteTaskList(),
                ),
              ],
            ),

            /// Past Records Tab
            Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  '지난 주 오늘 했던 일',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 2,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FutureBuilder<List<Task>>(
                    future: _taskManager.getTasksOneWeekAgo(DateTime.now()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return _buildPastTaskList(snapshot.data!);
                      } else {
                        return const Center(child: Text('No past tasks available.'));
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskForm() {
    return Form(
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
            onTap: _addTask,
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return ReorderableListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
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
            onTap: () => _addTaskToDate(task),
          ),
        );
      },
      onReorder: _reorderTasks,
    );
  }

  Widget _buildIncompleteTaskList() {
    return ReorderableListView.builder(
      itemCount: _incompleteTasks.length,
      itemBuilder: (context, index) {
        final task = _incompleteTasks[index];

        // Formatting date as 'yyyy-MM-dd'
        final formattedDate =
            "${task.date.year}-${task.date.month.toString().padLeft(2, '0')}-${task.date.day.toString().padLeft(2, '0')}";

        return Dismissible(
          key: ValueKey('${task.id}-${task.title}'),
          onDismissed: (direction) async {
            try {
              await _taskManager.deleteTask(task.id);

              setState(() {
                _incompleteTasks.removeAt(index); // 데이터와 UI 동기화
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task "${task.title}" deleted.')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to delete task: $e')),
              );
            }
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            title: Text("${task.title} - ($formattedDate 미완성)"),
            leading: const Icon(Icons.task),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _addTaskToDate(task),
          ),
        );
      },
      onReorder: _reorderIncompleteTasks,
    );
  }


  Widget _buildPastTaskList(List<Task> pastTasks) {
    return ReorderableListView.builder(
      itemCount: pastTasks.length,
      itemBuilder: (context, index) {
        final task = pastTasks[index];

        // Formatting date as 'yyyy-MM-dd'
        final formattedDate =
            "${task.date.year}-${task.date.month.toString().padLeft(2, '0')}-${task.date.day.toString().padLeft(2, '0')}";

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
            title: Text("${task.title} - ($formattedDate)"),
            leading: const Icon(Icons.task),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _addTaskToDate(task),
          ),
        );
      },
      onReorder: _reorderPastTasks,
    );
  }


  Future<void> _addTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        final userName = await _taskManager.currentUserName;

        // 중복 이름 확인
        final isDuplicate = _tasks.any((task) => task.title == _taskName);

        if (isDuplicate) {
          _taskName += '-중복'; // 중복일 경우 이름 뒤에 "-중복" 추가
        }

        // 데이터베이스에 추가
        await _taskManager.addToTaskList(_taskName, userName);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task "$_taskName" added successfully!')),
        );

        setState(() {
          _taskName = ""; // 입력 폼 초기화
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add task: $e')),
        );
      }
    }
  }


  Future<void> _addTaskToDate(Task task) async {
    try {
      final userName = await _taskManager.currentUserName;
      final newTask = Task(
        title: task.title,
        date: _date,
        userName: userName,
        isCompleted: false,
      );
      await _taskManager.addTask(newTask);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task "${task.title}" added to ${_date.toLocal()}!')),
      );
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;

    setState(() {
      final item = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, item);
    });
  }

  void _reorderIncompleteTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;

    setState(() {
      final item = _incompleteTasks.removeAt(oldIndex);
      _incompleteTasks.insert(newIndex, item);
    });
  }

  void _reorderPastTasks(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final task = _pastTasks.removeAt(oldIndex);
      _pastTasks.insert(newIndex, task);
    });
  }
}