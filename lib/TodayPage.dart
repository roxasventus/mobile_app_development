import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'TaskManager.dart';
import 'Task.dart';
import 'ReorderableTaskList.dart';
import 'SideMenu.dart';
import 'AddPage.dart';
import 'BackgroundContainer.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskManager = TaskManager();

    // 현재 날짜를 'x월 x일 오늘의 할일' 형식으로 변환
    String formattedDate = DateFormat('M월 d일').format(DateTime.now());

    // Function to reorder tasks
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
        title: Text('$formattedDate 오늘의 할일'),
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
        imagePath: 'assets/images/background.png', // 사용할 배경 이미지 경로
        child: StreamBuilder<List<Task>>(
          stream: taskManager.getTasksByDateStream(DateTime.now()),
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
                // 체크박스 클릭 시 완료 상태 토글
                taskManager.toggleTaskCompletion(taskId, currentStatus);
              },
              onDeleteTask: (taskId) {
                // 삭제 버튼 클릭 시 삭제
                taskManager.deleteTask(taskId);
              },
              onReorderTasks: (oldIndex, newIndex) {
                reorderTasks(tasks, oldIndex, newIndex);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPage(selectedDay: DateTime.now()),
            ),
          ).then((_) {
            // AddPage에서 돌아온 뒤 할 일이 추가됐을 경우,
            // StreamBuilder가 Firestore 변경사항을 감지 -> 자동 업데이트
          });
        },
      ),
    );
  }
}
