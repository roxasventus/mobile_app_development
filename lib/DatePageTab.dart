import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Task.dart';
import 'TaskManager.dart';
import 'AddPage.dart';
import 'BackgroundContainer.dart';
import 'TodayPage.dart'; // TodayPage import 필요 (날짜를 파라미터로 받는 TodayPage)

class DatePageTab extends StatelessWidget {
  final DateTime selectedDay;
  final TaskManager taskManager;
  final Function refreshTasks;

  const DatePageTab({
    super.key,
    required this.selectedDay,
    required this.taskManager,
    required this.refreshTasks,
  });

  @override
  Widget build(BuildContext context) {
    // 화면의 60% 높이 제한
    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return BackgroundContainer(
      imagePath: 'assets/images/background_datepageTab.png',
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
        ),
        child: StreamBuilder<List<Task>>(
          stream: taskManager.getTasksByDateStream(selectedDay),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('오류 발생: ${snapshot.error}'));
            }

            final tasks = snapshot.data ?? [];

            return Column(
              children: [
                const SizedBox(height: 24),
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(child: Text('저장한 할 일이 없습니다'))
                      : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) async {
                            if (value != null) {
                              try {
                                await taskManager.toggleTaskCompletion(
                                  task.id,
                                  task.isCompleted,
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('상태 업데이트 실패: $e')),
                                );
                              }
                            }
                          },
                        ),
                        title: Text(task.title),
                        subtitle: (task.startTime != null && task.endTime != null)
                            ? Text(
                          '시작: ${TimeOfDay.fromDateTime(task.startTime!).format(context)} - 끝: ${TimeOfDay.fromDateTime(task.endTime!).format(context)}',
                        )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await taskManager.deleteTask(task.id);
                              refreshTasks(selectedDay);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('삭제 실패: $e')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPage(selectedDay: selectedDay),
                          ),
                        );
                        if (result == true) {
                          refreshTasks(selectedDay);
                        }
                      },
                      child: const Icon(Icons.edit),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.pop(context); // BottomSheet 닫고
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TodayPage(selectedDay: selectedDay),
                          ),
                        );
                      },
                      child: const Icon(Icons.list), // 리스트 아이콘으로 변경
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}
