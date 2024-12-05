// lib/AddPage.dart
import 'package:flutter/material.dart';
import 'TaskManager.dart';
import 'Task.dart';
import 'SideMenu.dart';
import 'package:intl/intl.dart';

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
  DateTime? _startTime; // 기본: 00:00
  DateTime? _endTime;   // 기본: 00:10
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDay;

    // 기본 시간 설정: 00시 00분 - 00시 10분
    _startTime = DateTime(_date.year, _date.month, _date.day, 0, 0);
    _endTime = DateTime(_date.year, _date.month, _date.day, 0, 10);
  }

  // 시간을 10분 단위로 반올림하는 함수
  DateTime _roundToNearestTen(DateTime time) {
    int minute = time.minute;
    int roundedMinute = (minute / 10).round() * 10;
    if (roundedMinute == 60) {
      return DateTime(time.year, time.month, time.day, time.hour + 1, 0);
    }
    return DateTime(time.year, time.month, time.day, time.hour, roundedMinute);
  }

  // DateTime? 비교 함수 (null 고려) - 정렬용
  int compareTimes(DateTime? a, DateTime? b) {
    if (a != null && b != null) return a.compareTo(b);
    if (a == null && b == null) return 0;
    if (a == null) return 1; // a가 null이면 b가 우선
    return -1; // b가 null이면 a가 우선
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('M월 d일의 할일 추가').format(_date);

    return DefaultTabController(
      length: 3, // 할 일, 미완성, 과거기록 3개 탭
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(formattedDate),
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
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
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
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: '할 일 이름',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _taskName = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '할 일 이름을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '시작: ${TimeOfDay.fromDateTime(_startTime!).format(context)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: Icon(
                        Icons.access_time,
                        size: 24,
                        color: Colors.purple.shade700,
                      ),
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_startTime!),
                        );
                        if (picked != null) {
                          DateTime selectedTime = DateTime(
                            _date.year,
                            _date.month,
                            _date.day,
                            picked.hour,
                            picked.minute,
                          );
                          setState(() {
                            _startTime = _roundToNearestTen(selectedTime);
                            if (_endTime!.isBefore(_startTime!)) {
                              _endTime = _startTime!.add(const Duration(minutes: 10));
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '끝: ${TimeOfDay.fromDateTime(_endTime!).format(context)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: Icon(
                        Icons.access_time,
                        size: 24,
                        color: Colors.purple.shade700,
                      ),
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_endTime!),
                        );
                        if (picked != null) {
                          DateTime selectedTime = DateTime(
                            _date.year,
                            _date.month,
                            _date.day,
                            picked.hour,
                            picked.minute,
                          );
                          setState(() {
                            _endTime = _roundToNearestTen(selectedTime);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addTask,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('할일 추가'),
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

                // 필요시 정렬 로직 추가 가능 (compareTimes)

                if (tasks.isEmpty) {
                  return const Center(child: Text('미완성 할 일이 없습니다.'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: (task.startTime != null && task.endTime != null)
                          ? Text(
                        '시작: ${TimeOfDay.fromDateTime(task.startTime!).format(context)} - 끝: ${TimeOfDay.fromDateTime(task.endTime!).format(context)}',
                      )
                          : null,
                    );
                  },
                );
              },
            ),

            /// 과거 기록 탭
            FutureBuilder<List<Task>>(
              future: _taskManager.getTasksSevenDaysAgo(_date),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final tasks = snapshot.data ?? [];

                // 필요시 정렬 로직 추가 가능 (compareTimes)

                if (tasks.isEmpty) {
                  return const Center(child: Text('7일 전에 등록된 할 일이 없습니다.'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: (task.startTime != null && task.endTime != null)
                          ? Text(
                        '시작: ${TimeOfDay.fromDateTime(task.startTime!).format(context)} - 끝: ${TimeOfDay.fromDateTime(task.endTime!).format(context)}',
                      )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.add, color: Colors.blue),
                        onPressed: () async {
                          try {
                            final userName = await _taskManager.currentUserName;
                            final selectedDate = _date;
                            final newTask = Task(
                              title: task.title,
                              date: selectedDate,
                              userName: userName,
                              startTime: task.startTime != null
                                  ? DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                task.startTime!.hour,
                                task.startTime!.minute,
                              )
                                  : null,
                              endTime: task.endTime != null
                                  ? DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                task.endTime!.hour,
                                task.endTime!.minute,
                              )
                                  : null,
                            );
                            await _taskManager.addTask(newTask);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '할일 "${task.title}"이 ${DateFormat('M월 d일').format(selectedDate)}의 할 일에 추가되었습니다.',
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('할일 추가에 실패했습니다: $e')),
                            );
                          }
                        },
                      ),
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
      // 최소 시간 검증
      if (_endTime!.difference(_startTime!).inMinutes < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('최소 시간은 10분 이상이어야 합니다.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final userName = await _taskManager.currentUserName;
        final taskDate = DateTime(_date.year, _date.month, _date.day);

        final newTask = Task(
          title: _taskName,
          date: taskDate,
          userName: userName,
          startTime: _startTime,
          endTime: _endTime,
        );
        await _taskManager.addTask(newTask);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('할일 "$_taskName"이 성공적으로 추가되었습니다!')),
        );

        setState(() {
          _taskName = "";
          _startTime = DateTime(_date.year, _date.month, _date.day, 0, 0);
          _endTime = DateTime(_date.year, _date.month, _date.day, 0, 10);
        });

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('할일 추가에 실패했습니다: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
