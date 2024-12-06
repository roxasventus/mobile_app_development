import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'SideMenu.dart';

class WeekPage extends StatefulWidget {
  const WeekPage({super.key});

  @override
  State<WeekPage> createState() => _WeekPageState();
}

class _WeekPageState extends State<WeekPage> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> habitList = [];
  Map<String, bool> completionStatus = {};
  Map<String, int> streakCounts = {};

  @override
  void initState() {
    super.initState();
    _fetchHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('habit tracker'),
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
        children: [
          TableCalendar(
            focusedDay: selectedDate,
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            selectedDayPredicate: (day) => isSameDay(day, selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                selectedDate = selectedDay;
              });
              _fetchCompletionStatus(selectedDay);
              _fetchStreakCounts();
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '날짜: ${_dateString(selectedDate)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: habitList.length,
              itemBuilder: (context, index) {
                final habit = habitList[index];
                final isDone = completionStatus[habit['id']] ?? false;
                final streak = streakCounts[habit['id']] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(habit['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${streak}일째',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Checkbox(
                          value: isDone,
                          onChanged: (value) {
                            _updateCompletionStatus(habit['id'], selectedDate, value!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewHabit(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Firestore에서 모든 습관 리스트 가져오기
  Future<void> _fetchHabits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('habits')
        .where('userId', isEqualTo: user.uid) // UID 기준으로 필터링
        .get();

    setState(() {
      habitList = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    });

    _fetchCompletionStatus(selectedDate);
    _fetchStreakCounts();
  }

  // Firestore에서 완료 상태 업데이트
  Future<void> _updateCompletionStatus(String habitId, DateTime date, bool isDone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docId = '${habitId}_${_dateString(date)}';

    await FirebaseFirestore.instance.collection('completion').doc(docId).set({
      'userId': user.uid, // UID 저장
      'habitId': habitId,
      'date': _dateString(date),
      'isDone': isDone,
    });

    _fetchCompletionStatus(date);
    _fetchStreakCounts();
  }

  // Firestore에서 선택된 날짜의 완료 상태 가져오기
  Future<void> _fetchCompletionStatus(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('completion')
        .where('userId', isEqualTo: user.uid) // UID 기준으로 필터링
        .where('date', isEqualTo: _dateString(date))
        .get();

    final Map<String, bool> status = {};
    for (var doc in snapshot.docs) {
      status[doc['habitId']] = doc['isDone'] ?? false;
    }

    setState(() {
      completionStatus = status;
    });
  }

  // Firestore에서 선택된 날짜 기준 연속 일수 계산
  Future<void> _fetchStreakCounts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final Map<String, int> streakMap = {};

    for (var habit in habitList) {
      int streak = 0;
      DateTime current = selectedDate;

      while (true) {
        final docId = '${habit['id']}_${_dateString(current)}';
        final doc = await FirebaseFirestore.instance
            .collection('completion')
            .doc(docId)
            .get();

        if (doc.exists && doc.data()?['isDone'] == true) {
          streak++;
          current = current.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      streakMap[habit['id']] = streak;
    }

    setState(() {
      streakCounts = streakMap;
    });
  }

  // Firestore에서 새로운 습관 추가
  Future<void> _addNewHabit(BuildContext context) async {
    TextEditingController habitController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('새로운 습관 추가'),
          content: TextField(
            controller: habitController,
            decoration: const InputDecoration(hintText: '습관 이름'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                final habitName = habitController.text.trim();
                if (habitName.isNotEmpty) {
                  await _saveNewHabit(habitName);
                  Navigator.of(context).pop();
                  _fetchHabits();
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  // Firestore에서 새로운 습관 저장
  Future<void> _saveNewHabit(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('habits').add({
      'userId': user.uid, // UID 저장
      'name': name,
    });
  }

  // 날짜를 문자열로 변환
  String _dateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
