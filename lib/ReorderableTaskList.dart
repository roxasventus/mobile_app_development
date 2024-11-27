import 'package:flutter/material.dart';
import 'Task.dart';

class ReorderableTaskList extends StatelessWidget {
  final List<Task> tasks; // List of tasks
  final void Function(String taskId, bool isCompleted) onToggleTaskCompletion; // Callback for toggling completion
  final void Function(String taskId) onDeleteTask; // Callback for deleting a task
  final void Function(int oldIndex, int newIndex) onReorderTasks; // Callback for reordering tasks

  const ReorderableTaskList({
    Key? key,
    required this.tasks,
    required this.onToggleTaskCompletion,
    required this.onDeleteTask,
    required this.onReorderTasks,
  }) : super(key: key);

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
              onChanged: (value) {
                if (value != null) {
                  onToggleTaskCompletion(task.id, task.isCompleted);
                }
              },
            ),
            trailing: Icon(Icons.drag_handle),
          ),
          onDismissed: (direction) {
            onDeleteTask(task.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${task.title} deleted')),
            );
          },
        );
      },
      onReorder: (oldIndex, newIndex) {
        // Adjust index for proper reordering
        if (newIndex > oldIndex) newIndex -= 1;
        onReorderTasks(oldIndex, newIndex);
      },
    );
  }
}
