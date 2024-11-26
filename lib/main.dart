// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'LoginPage.dart';
import 'TaskProvider.dart'; // TaskProvider import
import 'TodayPage.dart';
import 'task.dart'; // Task model import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화
  await initializeDateFormatting('ko');
  runApp(
    ChangeNotifierProvider<TaskProvider>(
      create: (_) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // 인증된 경우 TodayPage로 이동
              return const TodayPage();
            } else {
              // 인증되지 않은 경우 LoginPage로 이동
              return const LoginPage();
            }
          } else {
            // 인증 상태를 확인 중일 때 로딩 화면 표시
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}

class ReorderableTaskList extends StatefulWidget {
  final List<Task> task;

  const ReorderableTaskList({Key? key, required this.task}) : super(key: key);

  @override
  _ReorderableTaskListState createState() => _ReorderableTaskListState();
}

class _ReorderableTaskListState extends State<ReorderableTaskList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: widget.task.length,
      itemBuilder: (context, index) {
        final task = widget.task[index];
        return Dismissible(
          background: Container(color: Colors.green),
          key: ValueKey(task.id), // Task ID를 키로 사용
          child: ListTile(
            title: Text('${task.title}: ${DateFormat('yyyy-MM-dd').format(task.date)}'),
            leading: Icon(
              task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
              color: task.isCompleted ? Colors.green : null,
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              Provider.of<TaskProvider>(context, listen: false).toggleTaskCompletion(task.id);
            },
          ),
          onDismissed: (direction) {
            Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${task.title} 삭제됨')),
            );
          },
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) newIndex -= 1;
          final Task movedTask = widget.task.removeAt(oldIndex);
          widget.task.insert(newIndex, movedTask);
          // Firestore에 순서를 저장하려면 추가 로직 필요
        });
      },
    );
  }
}
