import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'SideMenu.dart';
import 'BackgroundContainer.dart'; // BackgroundContainer import 추가

class WeekPage extends StatefulWidget {
  const WeekPage({super.key});

  @override
  State<WeekPage> createState() => _WeekPageState();
}

class _WeekPageState extends State<WeekPage> {
  DateTime selectedDate = DateTime.now();
  Map<String, DateTime?> lastSelectedDates = {};
  List<Map<String, dynamic>> habitList = [];
  Map<String, int> streakCounts = {};
  Map<String, bool> completionStatus = {};

  @override
  void initState() {
    super.initState();
    _fetchHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('habit tracker', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 35),),
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
        imagePath: 'assets/images/background.png', // 배경 이미지 지정
        child: Column(
          children: [
            TableCalendar(
              focusedDay: selectedDate,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(day, selectedDate),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                  for (var habit in habitList) {
                    lastSelectedDates[habit['id']] = selectedDay;
                  }
                });
                _fetchCompletionStatus(selectedDay);
                _fetchStreakCounts();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '날짜: ${_dateString(selectedDate)}',
                  style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: ReorderableListView(
                onReorder: _onReorder,
                children: [
                  for (int index = 0; index < habitList.length; index++)
                    Dismissible(
                      key: ValueKey(habitList[index]['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      ),
                      onDismissed: (direction) async {
                        await _deleteHabit(habitList[index]['id']);
                        setState(() {
                          habitList.removeAt(index);
                        });
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(habitList[index]['name'], style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 30)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${streakCounts[habitList[index]['id']] ?? 0}일째',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: '나눔손글씨_미니_손글씨.ttf',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Checkbox(
                                value: completionStatus[habitList[index]['id']] ?? false,
                                onChanged: (value) {
                                  _updateCompletionStatus(
                                    habitList[index]['id'],
                                    selectedDate,
                                    value!,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewHabit(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _fetchHabits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('habits')
        .where('userId', isEqualTo: user.uid)
        .orderBy('order')
        .get();

    setState(() {
      habitList = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    });

    _fetchCompletionStatus(selectedDate);
    _fetchStreakCounts();
  }

  Future<void> _fetchCompletionStatus(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('completion')
        .where('userId', isEqualTo: user.uid)
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

  Future<void> _fetchStreakCounts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final Map<String, int> streakMap = {};

    for (var habit in habitList) {
      int streak = 0;
      DateTime? lastSelectedDate = lastSelectedDates[habit['id']];
      if (lastSelectedDate == null) continue;

      DateTime current = lastSelectedDate;

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

  Future<void> _updateCompletionStatus(String habitId, DateTime date, bool isDone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docId = '${habitId}_${_dateString(date)}';

    try {
      await FirebaseFirestore.instance.collection('completion').doc(docId).set({
        'userId': user.uid,
        'habitId': habitId,
        'date': _dateString(date),
        'isDone': isDone,
      });

      setState(() {
        completionStatus[habitId] = isDone;
        _fetchStreakCounts();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상태 업데이트 실패: $e')),
      );
    }
  }

  Future<void> _deleteHabit(String habitId) async {
    await FirebaseFirestore.instance.collection('habits').doc(habitId).delete();
    await FirebaseFirestore.instance
        .collection('completion')
        .where('habitId', isEqualTo: habitId)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;

    final movedItem = habitList.removeAt(oldIndex);
    habitList.insert(newIndex, movedItem);

    setState(() {});

    await _updateOrderInFirestore();
  }

  Future<void> _updateOrderInFirestore() async {
    for (int i = 0; i < habitList.length; i++) {
      final habit = habitList[i];
      await FirebaseFirestore.instance
          .collection('habits')
          .doc(habit['id'])
          .update({'order': i});
    }
  }

  Future<void> _addNewHabit(BuildContext context) async {
    TextEditingController habitController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('새로운 습관 추가', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 30, fontWeight: FontWeight.bold),),
          content: TextField(
            controller: habitController,
            decoration: const InputDecoration(hintText: '습관 이름', hintStyle: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25),),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25),),
            ),
            TextButton(
              onPressed: () async {
                final habitName = habitController.text.trim();
                if (habitName.isNotEmpty) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final newHabit = await FirebaseFirestore.instance.collection('habits').add({
                      'userId': user.uid,
                      'name': habitName,
                      'order': habitList.length,
                    });

                    setState(() {
                      habitList.add({'id': newHabit.id, 'name': habitName, 'order': habitList.length});
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('추가', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25),),
            ),
          ],
        );
      },
    );
  }

  String _dateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
