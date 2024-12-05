// FeedBackPage.dart
import 'package:appproject/SideMenu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class FeedBackPage extends StatefulWidget {
  const FeedBackPage({super.key});

  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime selectedDate = DateTime.now();
  int weekOfYear = 1;

  double dailyCompletionRate = 0.0;
  double weeklyCompletionRate = 0.0;
  double monthlyCompletionRate = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCompletionRates(
      _getStartOfWeek(selectedDate),
      _getEndOfWeek(selectedDate),
    );
  }

  void _fetchCompletionRates(DateTime startOfWeek, DateTime endOfWeek) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userName = (await _firestore.collection('user').doc(user.uid).get())
        .data()?['userName'];

    if (userName == null) return;

    final tasksSnapshot = await _firestore
        .collection('tasks')
        .where('userName', isEqualTo: userName)
        .get();

    final tasks = tasksSnapshot.docs
        .map((doc) => {
      'isCompleted': doc['isCompleted'] as bool,
      'date': (doc['date'] as Timestamp).toDate()
    })
        .toList();

    setState(() {
      dailyCompletionRate = _calculateCompletionRate(
        tasks,
        selectedDate,
        selectedDate.add(Duration(hours: 23, minutes: 59, seconds: 59)),
      );
      weeklyCompletionRate = _calculateCompletionRate(
        tasks,
        startOfWeek,
        endOfWeek.add(Duration(hours: 23, minutes: 59, seconds: 59)),
      );
      monthlyCompletionRate = _calculateCompletionRate(
        tasks,
        DateTime(selectedDate.year, selectedDate.month, 1),
        DateTime(selectedDate.year, selectedDate.month + 1, 0),
      );
    });
  }

  double _calculateCompletionRate(
      List<Map<String, dynamic>> tasks, DateTime start, DateTime end) {
    final filteredTasks = tasks.where((task) {
      final taskDate = task['date'] as DateTime;
      return taskDate.isAfter(start) && taskDate.isBefore(end);
    }).toList();

    if (filteredTasks.isEmpty) return 0.0;

    final completedTasks = filteredTasks.where((task) => task['isCompleted']).length;
    return (completedTasks / filteredTasks.length) * 100;
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  DateTime _getEndOfWeek(DateTime date) {
    return _getStartOfWeek(date).add(Duration(days: 6));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
      weekOfYear = _calculateWeekOfYear(selectedDay);

      final startOfWeek = _getStartOfWeek(selectedDay);
      final endOfWeek = _getEndOfWeek(selectedDay);

      _fetchCompletionRates(startOfWeek, endOfWeek);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('피드백 페이지'),
      ),
      drawer: const SideMenu(),
      body: Column(
        children: <Widget>[
          TableCalendar(
            focusedDay: selectedDate,
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            selectedDayPredicate: (day) => isSameDay(day, selectedDate),
            onDaySelected: _onDaySelected,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 50,
            color: Colors.red.shade100,
            alignment: Alignment.center,
            child: Text(
              '${selectedDate.month}월 간 달성률: ${monthlyCompletionRate.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 25),
            ),
          ),
          Container(
            height: 50,
            color: Colors.blue.shade100,
            alignment: Alignment.center,
            child: Text(
              '${selectedDate.month}월 ${_calculateMonthWeek(selectedDate)}주 간 달성률: ${weeklyCompletionRate.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 25),
            ),
          ),
          Container(
            height: 50,
            color: Colors.green.shade100,
            alignment: Alignment.center,
            child: Text(
              '${selectedDate.month}/${selectedDate.day} 일간 달성률: ${dailyCompletionRate.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 25),
            ),
          ),
          const SizedBox(height: 20),
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
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final weekDayOfFirstDay = firstDayOfYear.weekday;
    final firstWeekStart = firstDayOfYear.add(Duration(days: (7 - weekDayOfFirstDay) % 7));
    final daysDifference = date.difference(firstWeekStart).inDays;

    return ((daysDifference) / 7).ceil() + 1;
  }

  int _calculateMonthWeek(DateTime date) {
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    int firstWeekday = firstDayOfMonth.weekday;

    DateTime firstSundayOfMonth =
    firstDayOfMonth.subtract(Duration(days: (firstWeekday % 7)));

    int daysDifference = date.difference(firstSundayOfMonth).inDays;

    return (daysDifference / 7).floor() + 1;
  }
}
