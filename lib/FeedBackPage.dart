import 'package:appproject/SideMenu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'BackgroundContainer.dart';

class FeedBackPage extends StatefulWidget {
  const FeedBackPage({super.key});

  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime selectedDate = DateTime.now();
  double dailyCompletionRate = 0.0;
  double weeklyCompletionRate = 0.0;
  double monthlyCompletionRate = 0.0;

  @override
  void initState() {
    super.initState();
    _updateCompletionRates();
  }

  void _updateCompletionRates() async {
    final startOfWeek = _getStartOfWeek(selectedDate);
    final endOfWeek = _getEndOfWeek(selectedDate);
    await _fetchCompletionRates(startOfWeek, endOfWeek);
  }

  Future<void> _fetchCompletionRates(DateTime startOfWeek, DateTime endOfWeek) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid; // 현재 로그인한 사용자의 UID

    final tasksSnapshot = await _firestore
        .collection('tasks')
        .where('userId', isEqualTo: uid)
        .get();

    final tasks = tasksSnapshot.docs.map((doc) {
      final data = doc.data();
      final rawDate = (data['date'] as Timestamp).toDate();
      final taskDate = _startOfDay(rawDate);

      return {
        'isCompleted': data['isCompleted'] as bool? ?? false,
        'date': taskDate,
      };
    }).toList();

    // 월간 마지막 날짜 계산
    final nextMonth = selectedDate.month == 12
        ? DateTime(selectedDate.year + 1, 1, 1)
        : DateTime(selectedDate.year, selectedDate.month + 1, 1);
    final lastDayOfMonth = nextMonth.subtract(const Duration(days: 1));

    setState(() {
      dailyCompletionRate = _calculateCompletionRate(
        tasks,
        _startOfDay(selectedDate),
        _endOfDay(selectedDate),
      );
      weeklyCompletionRate = _calculateCompletionRate(
        tasks,
        _startOfDay(startOfWeek),
        _endOfDay(endOfWeek),
      );
      monthlyCompletionRate = _calculateCompletionRate(
        tasks,
        _startOfDay(DateTime(selectedDate.year, selectedDate.month, 1)),
        _endOfDay(lastDayOfMonth),
      );
    });
  }

  double _calculateCompletionRate(
      List<Map<String, dynamic>> tasks, DateTime start, DateTime end) {
    final filteredTasks = tasks.where((task) {
      final taskDate = task['date'] as DateTime;
      return !taskDate.isBefore(start) && !taskDate.isAfter(end);
    }).toList();

    if (filteredTasks.isEmpty) return 0.0;

    final completedTasks =
        filteredTasks.where((task) => task['isCompleted'] == true).length;
    return (completedTasks / filteredTasks.length) * 100;
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: (date.weekday % 7)));
  }

  DateTime _getEndOfWeek(DateTime date) {
    return _getStartOfWeek(date).add(const Duration(days: 6));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
      _updateCompletionRates();
    });
  }

  int _calculateMonthWeek(DateTime date) {
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    int firstWeekday = firstDayOfMonth.weekday;
    DateTime firstSundayOfMonth =
    firstDayOfMonth.subtract(Duration(days: (firstWeekday % 7)));
    int daysDifference = date.difference(firstSundayOfMonth).inDays;
    return (daysDifference / 7).floor() + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('피드백 페이지'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/topbar_background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      drawer: const SideMenu(),
      body: BackgroundContainer(
        imagePath: 'assets/images/background.png',
        child: Column(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                color: Colors.red.shade100.withOpacity(0.8),
                alignment: Alignment.center,
                child: Text(
                  '${selectedDate.month}월 간 달성률: ${monthlyCompletionRate.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 25),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                color: Colors.blue.shade100.withOpacity(0.8),
                alignment: Alignment.center,
                child: Text(
                  '${selectedDate.month}월 ${_calculateMonthWeek(selectedDate)}주 간 달성률: ${weeklyCompletionRate.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 25),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                color: Colors.green.shade100.withOpacity(0.8),
                alignment: Alignment.center,
                child: Text(
                  '${selectedDate.month}/${selectedDate.day} 일간 달성률: ${dailyCompletionRate.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 25),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
