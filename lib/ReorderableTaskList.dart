import 'package:flutter/material.dart';
import 'Task.dart';

class ReorderableTaskList extends StatelessWidget {
  final List<Task> tasks; // List of tasks
  final void Function(String taskId, bool isCompleted) onToggleTaskCompletion; // Callback for toggling completion
  final void Function(String taskId) onDeleteTask; // Callback for deleting a task

  const ReorderableTaskList({
    Key? key,
    required this.tasks,
    required this.onToggleTaskCompletion,
    required this.onDeleteTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 시작시간 기준 정렬
    // 시작시간이 null일 경우를 대비해서 처리 로직을 추가할 수 있습니다.
    final sortedTasks = [...tasks]; // 기존 리스트를 복사한 뒤 정렬
    sortedTasks.sort((a, b) {
      final aTime = a.startTime;
      final bTime = b.startTime;

      if (aTime == null && bTime == null) return 0;  // 둘 다 시간이 없으면 같다고 처리
      if (aTime == null) return 1;                   // a만 null이면 뒤로
      if (bTime == null) return -1;                  // b만 null이면 b가 뒤로, 즉 a가 앞으로
      return aTime.compareTo(bTime);                 // 둘 다 null 아니면 시간 비교
    });

    return ListView.builder(
      itemCount: sortedTasks.length,
      itemBuilder: (context, index) {
        final task = sortedTasks[index];
        return Dismissible(
          key: ValueKey(task.id),
          background: Container(color: Colors.red),
          child: ListTile(
            title: Text(
              task.title,
              style: const TextStyle(
                  fontFamily: '나눔손글씨_미니_손글씨.ttf',
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),
            subtitle: task.startTime != null && task.endTime != null
                ? Text(
                '${TimeOfDay.fromDateTime(task.startTime!).format(context)} - ${TimeOfDay.fromDateTime(task.endTime!).format(context)}',
                style: const TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 20)
            )
                : null,
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                if (value != null) {
                  onToggleTaskCompletion(task.id, task.isCompleted);
                }
              },
            ),
          ),
          onDismissed: (direction) {
            onDeleteTask(task.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${task.title} deleted')),
            );
          },
        );
      },
    );
  }
}
