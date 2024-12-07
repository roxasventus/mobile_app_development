import 'package:flutter/material.dart';
import 'TaskManager.dart';
import 'Task.dart';
import 'package:intl/intl.dart';

class AddPagePast extends StatelessWidget {
  final DateTime selectedDay;
  final TaskManager _taskManager = TaskManager();

  AddPagePast({super.key, required this.selectedDay});

  Future<void> _addTaskForSelectedDay(BuildContext context, Task pastTask) async {
    try {
      final newTask = Task(
        title: pastTask.title,
        date: DateTime(selectedDay.year, selectedDay.month, selectedDay.day),
        userId: await _taskManager.currentUserId,
        startTime: DateTime(selectedDay.year, selectedDay.month, selectedDay.day,
            pastTask.startTime?.hour ?? 0, pastTask.startTime?.minute ?? 0),
        endTime: DateTime(selectedDay.year, selectedDay.month, selectedDay.day,
            pastTask.endTime?.hour ?? 0, pastTask.endTime?.minute ?? 0),
      );

      await _taskManager.addTask(newTask);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('선택한 날짜에 "${pastTask.title}"이 추가되었습니다!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('할일 추가 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16.0),
        Center(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              "지난주 오늘 할일",
              style: const TextStyle(
                fontSize: 20,
                fontFamily: '나눔손글씨_미니_손글씨.ttf',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: FutureBuilder<List<Task>>(
            future: _taskManager.getTasksSevenDaysAgo(selectedDay),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final tasks = snapshot.data ?? [];
              if (tasks.isEmpty) {
                return const Center(child: Text('지난 7일간 기록이 없습니다.', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 30)));
              }
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task.title, style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 20, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${DateFormat('M월 d일').format(task.date)}\n'
                          '시작: ${TimeOfDay.fromDateTime(task.startTime!).format(context)} - '
                          '끝: ${TimeOfDay.fromDateTime(task.endTime!).format(context)}',
                        style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 20)
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      onPressed: () => _addTaskForSelectedDay(context, task),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
