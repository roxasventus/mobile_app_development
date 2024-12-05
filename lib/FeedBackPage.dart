// FeedBackPage.dart
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
    _fetchCompletionRates(
      _getStartOfWeek(selectedDate),
      _getEndOfWeek(selectedDate),
    );
  }

  void _fetchCompletionRates(DateTime startOfWeek, DateTime endOfWeek) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('user').doc(user.uid).get();
    final userName = userDoc.data()?['userName'];
    if (userName == null) return;

    // Firestore에서 tasks 가져오기 (이제 date 대신 startTime, endTime 사용)
    final tasksSnapshot = await _firestore
        .collection('tasks')
        .where('userName', isEqualTo: userName)
        .get();

    // tasks: { 'isCompleted': bool, 'startTime': DateTime?, 'endTime': DateTime? }
    final tasks = tasksSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'isCompleted': data['isCompleted'] as bool? ?? false,
        'startTime': data['startTime'] != null
            ? (data['startTime'] as Timestamp).toDate()
            : null,
        'endTime': data['endTime'] != null
            ? (data['endTime'] as Timestamp).toDate()
            : null,
      };
    }).toList();

    setState(() {
      // dailyCompletionRate
      dailyCompletionRate = _calculateCompletionRate(
        tasks,
        _startOfDay(selectedDate),
        _endOfDay(selectedDate),
      );

      // weeklyCompletionRate
      weeklyCompletionRate = _calculateCompletionRate(
        tasks,
        startOfWeek,
        endOfWeek,
      );

      // monthlyCompletionRate
      final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
      final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0, 23, 59, 59, 999);
      monthlyCompletionRate = _calculateCompletionRate(
        tasks,
        startOfMonth,
        endOfMonth,
      );
    });
  }

  double _calculateCompletionRate(
      List<Map<String, dynamic>> tasks, DateTime start, DateTime end) {
    // 주어진 기간 내에 해당하는 작업만 필터링
    final filteredTasks = tasks.where((task) {
      final endTime = task['endTime'] as DateTime?;
      final startTime = task['startTime'] as DateTime?;

      // endTime 우선, 없으면 startTime 사용
      final taskDate = endTime ?? startTime;

      if (taskDate == null) {
        // 시작/끝 시간이 전혀 없는 작업은 기간 내 포함시키지 않음
        return false;
      }

      // 기간 내 포함 여부 확인 (start <= taskDate <= end)
      // 기존 조건: isAfter(start) && isBefore(end)
      // end를 포함하려면 isBefore(end.add(Duration(microseconds:1))) 하면 되지만
      // 여기서는 strict 하게 start < taskDate < end 로 처리
      return taskDate.isAfter(start) && taskDate.isBefore(end);
    }).toList();

    if (filteredTasks.isEmpty) return 0.0;

    // 필터링된 작업 중 완료된 작업 수
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
    // 주 시작: 주일(일요일)기준이거나 월요일 기준인지에 따라 변동가능
    // 여기서는 기존 코드대로 유지
    return date.subtract(Duration(days: (date.weekday % 7)));
  }

  DateTime _getEndOfWeek(DateTime date) {
    return _getStartOfWeek(date).add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
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
