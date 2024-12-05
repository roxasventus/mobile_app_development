// lib/TodayPage.dart
import 'package:flutter/material.dart';
import 'TaskManager.dart';
import 'Task.dart';
import 'ReorderableTaskList.dart';
import 'SideMenu.dart';
import 'AddPage.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 위한 패키지 임포트

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskManager = TaskManager();

    // 현재 날짜를 가져와서 'x월 x일 오늘의 할일' 형식으로 변환
    String formattedDate = DateFormat('M월 d일').format(DateTime.now());

    // Function to reorder tasks
    void reorderTasks(List<Task> tasks, int oldIndex, int newIndex) async {
      if (newIndex > oldIndex) newIndex -= 1; // Adjust index for reordering logic
      final task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);

      // Update the order in Firestore if needed
      for (int i = 0; i < tasks.length; i++) {
        await taskManager.updateTaskOrder(tasks[i].id, i); // Implemented in TaskManager
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$formattedDate 오늘의 할일'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
      body: StreamBuilder<List<Task>>(
        stream: taskManager.fetchTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('작업을 불러오는 중 오류가 발생했습니다.'));
          }
          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return const Center(child: Text('할 일이 없습니다.'));
          }
          return ReorderableTaskList(
            tasks: tasks,
            onToggleTaskCompletion: (taskId, currentStatus) {
              taskManager.toggleTaskCompletion(taskId, currentStatus);
            },
            onDeleteTask: (taskId) {
              taskManager.deleteTask(taskId);
            },
            onReorderTasks: (oldIndex, newIndex) {
              reorderTasks(tasks, oldIndex, newIndex);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPage(selectedDay: DateTime.now()), // 오늘 날짜를 전달
            ),
          );
        },
      ),
    );
  }
}
