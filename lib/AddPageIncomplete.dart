import 'package:flutter/material.dart';
import 'TaskManager.dart';
import 'Task.dart';
import 'package:intl/intl.dart';

class AddPageIncomplete extends StatelessWidget {
  final TaskManager _taskManager = TaskManager();

  AddPageIncomplete({super.key});

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
              "미완성 할 일",
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
          child: StreamBuilder<List<Task>>(
            stream: _taskManager.getIncompleteTasksStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final tasks = snapshot.data ?? [];
              if (tasks.isEmpty) {
                return const Center(child: Text('미완성 할 일이 없습니다.', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 30)));
              }
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task.title, style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 20, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${DateFormat('M월 d일').format(task.date)}\n'
                          '${TimeOfDay.fromDateTime(task.startTime!).format(context)} - '
                          '${TimeOfDay.fromDateTime(task.endTime!).format(context)}',
                        style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 20)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _taskManager.deleteTask(task.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('할 일 "${task.title}"이 삭제되었습니다.')),
                        );
                      },
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
