import 'package:flutter/material.dart';
import 'TaskManager.dart';
import 'Task.dart';
import 'package:intl/intl.dart';

class AddPageIncomplete extends StatelessWidget {
  final TaskManager _taskManager = TaskManager();

  AddPageIncomplete({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
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
          return const Center(child: Text('미완성 할 일이 없습니다.'));
        }
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text(
                '${DateFormat('M월 d일').format(task.date)}\n'
                    '시작: ${TimeOfDay.fromDateTime(task.startTime!).format(context)} - '
                    '끝: ${TimeOfDay.fromDateTime(task.endTime!).format(context)}',
              ),
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
    );
  }
}
