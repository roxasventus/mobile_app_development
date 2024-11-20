// lib/FeedBackPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'SideMenu.dart';
import 'TaskProvider.dart';
import 'task.dart';

class FeedBackPage extends StatefulWidget {
  const FeedBackPage({super.key});

  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  int weekOfYear = 1; // 초기 주차 설정
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('날짜 단위 피드백'),
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
      body: Column(
        children: <Widget>[
          TableCalendar(
            focusedDay: selectedDate,
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                selectedDate = selectedDay;
                weekOfYear = _calculateWeekOfYear(selectedDay);
              });
              // 필요 시 Firestore에서 피드백 데이터 가져오기
            },
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.purple, width: 1.5),
              ),
              todayTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              selectedDecoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              defaultDecoration: BoxDecoration(shape: BoxShape.circle),
              weekendDecoration: BoxDecoration(shape: BoxShape.circle),
              outsideDaysVisible: false,
            ),
          ),
          _buildFeedbackCard(
            '${selectedDate.month}월 간 달성률',
            _calculateMonthlyCompletionRate(selectedDate),
            Colors.red.shade100,
          ),
          _buildFeedbackCard(
            '${selectedDate.month}월 ${weekOfYear}주 간 달성률',
            _calculateWeeklyCompletionRate(selectedDate),
            Colors.blue.shade100,
          ),
          _buildFeedbackCard(
            '${selectedDate.month}/${selectedDate.day} 일간 달성률',
            _calculateDailyCompletionRate(selectedDate),
            Colors.green.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(String title, double rate, Color color) {
    return Container(
      height: 50,
      color: color,
      alignment: Alignment.center,
      child: Text(
        '$title : ${rate.toStringAsFixed(1)}%',
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  int _calculateWeekOfYear(DateTime date) {
    // 해당 월의 첫 번째 날을 기준으로 주차 계산
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    int dayOfMonth = date.day;
    int firstWeekday = firstDayOfMonth.weekday;

    // 첫째 주의 남은 날 + 현재 날짜까지의 차이를 7로 나누어 주차 계산
    return ((dayOfMonth + firstWeekday - 1) / 7).ceil();
  }

  // 월간 완료율 계산
  double _calculateMonthlyCompletionRate(DateTime date) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    List<Task> monthlyTasks = taskProvider.allTasks.where((task) =>
    task.date.year == date.year && task.date.month == date.month).toList();
    if (monthlyTasks.isEmpty) return 0.0;
    int completed = monthlyTasks.where((task) => task.isCompleted).length;
    return (completed / monthlyTasks.length) * 100;
  }

  // 주간 완료율 계산
  double _calculateWeeklyCompletionRate(DateTime date) {
    // 해당 주의 시작과 끝 날짜 계산
    DateTime firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    DateTime lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    List<Task> weeklyTasks = taskProvider.allTasks.where((task) =>
    task.date.isAfter(firstDayOfWeek.subtract(const Duration(days: 1))) &&
        task.date.isBefore(lastDayOfWeek.add(const Duration(days: 1)))).toList();
    if (weeklyTasks.isEmpty) return 0.0;
    int completed = weeklyTasks.where((task) => task.isCompleted).length;
    return (completed / weeklyTasks.length) * 100;
  }

  // 일간 완료율 계산
  double _calculateDailyCompletionRate(DateTime date) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    List<Task> dailyTasks = taskProvider.getTasksByDate(date);
    if (dailyTasks.isEmpty) return 0.0;
    int completed = dailyTasks.where((task) => task.isCompleted).length;
    return (completed / dailyTasks.length) * 100;
  }
}
