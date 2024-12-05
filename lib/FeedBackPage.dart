// lib/FeedBackPage.dart
import 'package:appproject/SideMenu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

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
    _updateCompletionRates();
  }

  void _updateCompletionRates() {
    final startOfWeek = _getStartOfWeek(selectedDate);
    final endOfWeek = _getEndOfWeek(selectedDate);
    _fetchCompletionRates(startOfWeek, endOfWeek);
  }

  void _fetchCompletionRates(DateTime startOfWeek, DateTime endOfWeek) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('user').doc(user.uid).get();
    final userName = userDoc.data()?['userName'];
    if (userName == null) return;

    // Firestore에서 tasks 가져오기
    final tasksSnapshot = await _firestore
        .collection('tasks')
        .where('userName', isEqualTo: userName)
        .get();

    // tasks: { 'isCompleted': bool, 'date': DateTime }
    final tasks = tasksSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final rawDate = (data['date'] as Timestamp).toDate();
      final taskDate = _startOfDay(rawDate); // 날짜 단위로만 비교하기 위해 0시로 맞춤

      return {
        'isCompleted': data['isCompleted'] as bool? ?? false,
        'date': taskDate,
      };
    }).toList();

    // 일간 계산
    final dailyRate = _calculateCompletionRate(
      tasks,
      _startOfDay(selectedDate),
      _endOfDay(selectedDate),
    );

    // 주간 계산
    final weeklyRate = _calculateCompletionRate(
      tasks,
      _startOfDay(startOfWeek),
      _endOfDay(endOfWeek),
    );

    // 월간 계산
    final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    // 다음달 1일에서 하루 빼면 말일이 나옴
    final nextMonthFirst = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    final endOfMonthDate = nextMonthFirst.subtract(const Duration(days: 1));
    final monthlyRate = _calculateCompletionRate(
      tasks,
      _startOfDay(startOfMonth),
      _endOfDay(endOfMonthDate),
    );

    setState(() {
      dailyCompletionRate = dailyRate;
      weeklyCompletionRate = weeklyRate;
      monthlyCompletionRate = monthlyRate;
    });
  }

  double _calculateCompletionRate(
      List<Map<String, dynamic>> tasks, DateTime start, DateTime end) {
    // 날짜 단위 비교를 위해 start, end 이미 _startOfDay, _endOfDay에서 처리
    // start <= taskDate <= end
    final filteredTasks = tasks.where((task) {
      final taskDate = (task['date'] as DateTime);
      return !taskDate.isBefore(start) && !taskDate.isAfter(end);
    }).toList();

    if (filteredTasks.isEmpty) return 0.0;

    final completedTasks = filteredTasks.where((task) => task['isCompleted'] == true).length;
    return (completedTasks / filteredTasks.length) * 100;
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  DateTime _getStartOfWeek(DateTime date) {
    // 주 시작일: 일요일 기준
    return date.subtract(Duration(days: (date.weekday % 7)));
  }

  DateTime _getEndOfWeek(DateTime date) {
    return _getStartOfWeek(date).add(const Duration(days: 6));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
      weekOfYear = _calculateWeekOfYear(selectedDay);
      _updateCompletionRates();
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
