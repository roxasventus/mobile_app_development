// lib/AddPage.dart
import 'package:flutter/material.dart';
import 'TaskManager.dart';
import 'Task.dart';
import 'SideMenu.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 위한 패키지 임포트

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
  DateTime? _endTime; // 추가된 필드
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDay;
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

  @override
  Widget build(BuildContext context) {
    // 선택된 날짜를 'x월 x일의 할일 추가' 형식으로 변환
    String formattedDate = DateFormat('M월 d일의 할일 추가').format(_date);

    return DefaultTabController(
      length: 3, // 탭 수
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
              Tab(text: '할 일'), // Task Tab
              Tab(text: '미완성'), // Incomplete Tab
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
                    // 할 일 이름 입력 필드
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
                    // 시작 시간 선택
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _startTime == null
                            ? '시작'
                            : '시작: ${TimeOfDay.fromDateTime(_startTime!).format(context)}',
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
                          initialTime: TimeOfDay.now(),
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
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    // 끝 시간 선택
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _endTime == null
                            ? '끝'
                            : '끝: ${TimeOfDay.fromDateTime(_endTime!).format(context)}',
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
                          initialTime: _startTime != null
                              ? TimeOfDay.fromDateTime(_startTime!)
                              : TimeOfDay.now(),
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
                    // 할일 추가 버튼
                    ElevatedButton(
                      onPressed: _addTask,
                      style: ElevatedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 16.0),
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
                    (tasks) =>
                    tasks.where((task) => !task.isCompleted).toList(),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}'));
                }
                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) {
                  return const Center(
                      child: Text('미완성 할 일이 없습니다.'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle:
                      task.startTime != null && task.endTime != null
                          ? Text(
                        '시작: ${TimeOfDay.fromDateTime(task.startTime!).format(context)} - 끝: ${TimeOfDay.fromDateTime(task.endTime!).format(context)}',
                      )
                          : null,
                      // 버튼이나 아이콘 없이 단순히 할 일 목록만 표시
                    );
                  },
                );
              },
            ),

            /// 과거 기록 탭
            FutureBuilder<List<Task>>(
              future:
              _taskManager.getTasksOneWeekAgo(DateTime.now()),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}'));
                }
                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) {
                  return const Center(
                      child: Text('지난주에 등록된 할 일이 없습니다.'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle:
                      task.startTime != null && task.endTime != null
                          ? Text(
                        '시작: ${TimeOfDay.fromDateTime(task.startTime!).format(context)} - 끝: ${TimeOfDay.fromDateTime(task.endTime!).format(context)}',
                      )
                          : null,
                      onTap: () async {
                        // 해당 할 일을 선택된 날짜로 추가
                        try {
                          final userName =
                          await _taskManager.currentUserName;
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
                                    '할일 "${task.title}"이 ${DateFormat('M월 d일').format(selectedDate)}의 할 일에 추가되었습니다.')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('할일 추가에 실패했습니다: $e')),
                          );
                        }
                      },
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
          const SnackBar(
              content: Text('시작 시간과 끝 시간을 선택해주세요.')),
        );
        return;
      }
      if (_endTime!.isBefore(_startTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('끝 시간은 시작 시간 이후여야 합니다.')),
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
          SnackBar(
              content: Text('할일 "$_taskName"이 성공적으로 추가되었습니다!')),
        );

        setState(() {
          _taskName = ""; // 입력 폼 초기화
          _startTime = null; // 시작 시간 초기화
          _endTime = null; // 끝 시간 초기화
        });

        Navigator.pop(context); // 추가 후 이전 화면으로 돌아가기
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
