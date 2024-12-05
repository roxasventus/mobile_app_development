// lib/AddPage.dart
import 'package:flutter/material.dart';
import 'TaskManager.dart';
import 'Task.dart';
import 'SideMenu.dart';

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
  DateTime? _startTime; // 추가된 필드
  DateTime? _endTime;   // 추가된 필드
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 탭 수
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
              Tab(text: '할 일'),    // Task Tab
              Tab(text: '미완성'),   // Incomplete Tab
              Tab(text: '과거기록'), // Past Records Tab
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
        drawer: const SideMenu(),
        body: TabBarView(
          children: [
            /// 할 일 추가 탭
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Task Name 입력 필드
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Task Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _taskName = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a task name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // 시작 시간 선택
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_startTime == null
                          ? 'Start Time'
                          : 'Start: ${TimeOfDay.fromDateTime(_startTime!).format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _startTime = DateTime(
                              _date.year,
                              _date.month,
                              _date.day,
                              picked.hour,
                              picked.minute,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    // 끝 시간 선택
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_endTime == null
                          ? 'End Time'
                          : 'End: ${TimeOfDay.fromDateTime(_endTime!).format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _startTime != null
                              ? TimeOfDay.fromDateTime(_startTime!)
                              : TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _endTime = DateTime(
                              _date.year,
                              _date.month,
                              _date.day,
                              picked.hour,
                              picked.minute,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // 추가 버튼
                    ElevatedButton(
                      onPressed: _addTask,
                      child: const Text('Add Task'),
                    ),
                  ],
                ),
              ),
            ),

            /// 미완성 할 일 탭
            FutureBuilder<List<Task>>(
              future: _taskManager.fetchTasksStream().first.then(
                    (tasks) => tasks.where((task) => !task.isCompleted).toList(),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) {
                  return const Center(child: Text('미완성 할 일이 없습니다.'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: task.startTime != null && task.endTime != null
                          ? Text(
                          'Start: ${TimeOfDay.fromDateTime(task.startTime!).format(context)} - End: ${TimeOfDay.fromDateTime(task.endTime!).format(context)}')
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          _taskManager.toggleTaskCompletion(task.id, task.isCompleted);
                        },
                      ),
                    );
                  },
                );
              },
            ),

            /// 과거 기록 탭
            FutureBuilder<List<Task>>(
              future: _taskManager.getTasksOneWeekAgo(DateTime.now()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) {
                  return const Center(child: Text('지난 주에 완료한 할 일이 없습니다.'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: task.startTime != null && task.endTime != null
                          ? Text(
                          'Start: ${TimeOfDay.fromDateTime(task.startTime!).format(context)} - End: ${TimeOfDay.fromDateTime(task.endTime!).format(context)}')
                          : null,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end times.')),
        );
        return;
      }
      if (_endTime!.isBefore(_startTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final userName = await _taskManager.currentUserName;

        // 데이터베이스에 추가
        final newTask = Task(
          title: _taskName,
          date: _date,
          userName: userName,
          startTime: _startTime,
          endTime: _endTime,
        );
        await _taskManager.addTask(newTask);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task "$_taskName" added successfully!')),
        );

        setState(() {
          _taskName = ""; // 입력 폼 초기화
          _startTime = null; // 시작 시간 초기화
          _endTime = null;   // 끝 시간 초기화
        });

        Navigator.pop(context); // 추가 후 이전 화면으로 돌아가기
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add task: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
