// lib/ReorderableTaskList.dart
import 'package:flutter/material.dart';
import 'task.dart';
import 'package:provider/provider.dart';
import 'TaskProvider.dart';

class ReorderableTaskList extends StatelessWidget {
  final List<Task> tasks; // 인수 이름을 'tasks'로 변경

  const ReorderableTaskList({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Dismissible(
          key: ValueKey(task.id),
          background: Container(color: Colors.green),
          child: ListTile(
            title: Text(task.title),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) {
                Provider.of<TaskProvider>(context, listen: false)
                    .toggleTaskCompletion(task.id);
              },
            ),
            trailing: Icon(Icons.drag_handle),
          ),
          onDismissed: (direction) {
            Provider.of<TaskProvider>(context, listen: false)
                .deleteTask(task.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${task.title} 삭제됨')),
            );
          },
        );
      },
      onReorder: (oldIndex, newIndex) {
        // 재정렬 로직 추가 (Firestore에 순서를 저장하려면 추가 작업 필요)
      },
    );
  }
}
