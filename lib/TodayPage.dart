import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'TaskManager.dart';
import 'Task.dart';
import 'ReorderableTaskList.dart';
import 'SideMenu.dart';
import 'AddPage.dart';
import 'BackgroundContainer.dart';
import 'TodayPageGrid.dart'; // 별도로 구현한 TodayPageGrid 위젯 import

class TodayPage extends StatelessWidget {
  final DateTime selectedDay; // 날짜를 외부로부터 받음

  const TodayPage({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final taskManager = TaskManager();

    // 선택한 날짜를 'M월 d일' 형식으로 변환
    String formattedDate = DateFormat('M월 d일').format(selectedDay);

    // 할 일 순서 재정렬 함수
    void reorderTasks(List<Task> tasks, int oldIndex, int newIndex) async {
      if (newIndex > oldIndex) newIndex -= 1;
      final task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);

      // Firestore의 order 업데이트
      for (int i = 0; i < tasks.length; i++) {
        await taskManager.updateTaskOrder(tasks[i].id, i);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$formattedDate의 할일'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/topbar_background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
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
      body: BackgroundContainer(
        imagePath: 'assets/images/background.png',
        child: Column(
          children: [
            // 상단 50% 영역: TodayPageGrid를 이용해 시간표 표시
            Flexible(
              flex: 1,
              child: StreamBuilder<List<Task>>(
                stream: taskManager.getTasksByDateStream(selectedDay),
                builder: (context, snapshot) {
                  final tasks = snapshot.data ?? [];
                  // tasks를 TodayPageGrid에 전달
                  return TodayPageGrid(tasks: tasks);
                },
              ),
            ),
            // 하단 50% 영역: 할 일 목록 표시
            Flexible(
              flex: 1,
              child: StreamBuilder<List<Task>>(
                stream: taskManager.getTasksByDateStream(selectedDay),
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // AddPage를 열 때도 selectedDay를 전달
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPage(selectedDay: selectedDay),
            ),
          ).then((_) {
            // AddPage에서 돌아온 뒤 할 일 추가 시 자동 업데이트 (StreamBuilder로)
          });
        },
      ),
    );
  }
}
