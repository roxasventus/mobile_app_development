// lib/DatePage.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'TaskManager.dart';
import 'Task.dart';
import 'SideMenu.dart';
import 'AddPage.dart';

class DatePage extends StatefulWidget {
  const DatePage({super.key});

  @override
  State<DatePage> createState() => _DatePageState();
}

class _DatePageState extends State<DatePage> {
  final TaskManager _taskManager = TaskManager();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('날짜별 할 일'),
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
      ),
      drawer: const SideMenu(),
      body: Column(
        children: [
          // 달력 위젯
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _calendarFormat = CalendarFormat.month;
                });
                _showTasksBottomSheet(selectedDay);
              }
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              // 추가 동작 필요 시 구현
            },
          ),
          // 추가적인 위젯들 (필요 시)
        ],
      ),
    );
  }

  void _showTasksBottomSheet(DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 전체 화면으로 확장 가능
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: TaskBottomSheet(
            selectedDate: selectedDate,
            taskManager: _taskManager,
          ),
        );
      },
    );
  }
}

class TaskBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final TaskManager taskManager;

  const TaskBottomSheet({
    super.key,
    required this.selectedDate,
    required this.taskManager,
  });

  @override
  State<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends State<TaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String _taskName = "";
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isLoading = false;
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = widget.taskManager.getTasksByDate(widget.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // 내용이 많을 경우 스크롤 가능하도록
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.selectedDate.toLocal()}'.split(' ')[0],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // 기존 할 일 목록
          FutureBuilder<List<Task>>(
            future: _tasksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final tasks = snapshot.data ?? [];
              if (tasks.isEmpty) {
                return const Center(child: Text('할 일이 없습니다.'));
              }
              return ListView.builder(
                shrinkWrap: true, // 리스트가 전체 화면을 차지하지 않도록 설정
                physics: const NeverScrollableScrollPhysics(), // 내부 스크롤 방지
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: task.startTime != null && task.endTime != null
                        ? Text(
                        'Start: ${TimeOfDay.fromDateTime(task.startTime!).format(context)} - End: ${TimeOfDay.fromDateTime(task.endTime!).format(context)}')
                        : null,
                    trailing: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) async {
                        await widget.taskManager.toggleTaskCompletion(task.id, task.isCompleted);
                        setState(() {
                          _tasksFuture = widget.taskManager.getTasksByDate(widget.selectedDate);
                        });
                      },
                    ),
                  );
                },
              );
            },
          ),
          const Divider(),
          // 새로운 할 일 추가 폼
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 10),
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
                          widget.selectedDate.year,
                          widget.selectedDate.month,
                          widget.selectedDate.day,
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
                          widget.selectedDate.year,
                          widget.selectedDate.month,
                          widget.selectedDate.day,
                          picked.hour,
                          picked.minute,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                // 좌우 버튼 (플러스 & 리스트)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 플러스 버튼
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // 새로운 할 일 추가 버튼 동작 (이미 폼에 있으므로 필요 시 다른 기능 추가)
                        _addTask();
                      },
                    ),
                    // 리스트 버튼
                    IconButton(
                      icon: const Icon(Icons.list),
                      onPressed: () {
                        // 할 일 리스트 관련 기능 (예: 할 일 수정 또는 재정렬)
                        // 여기서는 간단히 메시지로 표시
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('리스트 버튼 클릭됨')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 추가 버튼
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add Task'),
                ),
              ],
            ),
          ),
        ],
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
        final userName = await widget.taskManager.currentUserName;

        // 데이터베이스에 추가
        final newTask = Task(
          title: _taskName,
          date: widget.selectedDate,
          userName: userName,
          startTime: _startTime,
          endTime: _endTime,
        );
        await widget.taskManager.addTask(newTask);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task "$_taskName" added successfully!')),
        );

        setState(() {
          _taskName = ""; // 입력 폼 초기화
          _startTime = null; // 시작 시간 초기화
          _endTime = null;   // 끝 시간 초기화
          _tasksFuture = widget.taskManager.getTasksByDate(widget.selectedDate); // 업데이트
        });
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
