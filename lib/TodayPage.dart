// lib/TodayPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'SideMenu.dart';
import 'TaskProvider.dart';
import 'task.dart';
import 'AddPage.dart';
import 'ReorderableTaskList.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('오늘의 할 일'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu), // 햄버거 버튼 아이콘 생성
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: SideMenu(),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.allTasks;
          if (tasks.isEmpty) {
            return Center(child: Text('할 일이 없습니다.'));
          }
          return ReorderableTaskList(tasks: tasks); // 'tasks'로 변경
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // AddPage로 네비게이션 (특정 날짜 없이)
          Navigator.pushNamed(context, '/Today/Add', arguments: null);
        },
      ),
    );
  }
}
