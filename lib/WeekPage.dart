// lib/WeekPage.dart
import 'package:appproject/SideMenu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 유저 정보 가져오기 위해 필요
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class WeekPage extends StatefulWidget {
  const WeekPage({super.key});

  @override
  State<WeekPage> createState() => _WeekPageState();
}

class _WeekPageState extends State<WeekPage> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('습관 트래커'),
        leading: Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu),
              );
            }
        ),
      ),
      drawer: const SideMenu(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                selectedDate = selectedDay;
              });
              _showBottomSheet(context, selectedDay);
            },
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context, DateTime selectedDay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _getHabitData(selectedDay), // 선택한 날짜의 습관 데이터 가져오기
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            bool isDone = snapshot.data?['isDone'] ?? false;
            int streak = snapshot.data?['streak'] ?? 0;

            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd').format(selectedDay),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // 현재 연속 일수 표시
                  Text(
                    '현재 $streak일째 지속중!',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: const Text('이 날 습관 수행함'),
                    value: isDone,
                    onChanged: (value) async {
                      await _setHabitDone(selectedDay, value!);
                      // 변경사항 반영을 위해 다시 빌드
                      setState(() {});
                    },
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          // 편집 등의 기능을 추후 구현 가능
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('편집 기능 미구현')),
                          );
                        },
                        child: const Icon(Icons.edit),
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // 다른 페이지로 이동 가능
                          // Navigator.of(context).push(...);
                        },
                        child: const Icon(Icons.format_list_bulleted),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Firestore에서 해당 날짜의 습관 데이터 가져오기
  // isDone 여부와 streak 계산 결과 반환
  Future<Map<String, dynamic>> _getHabitData(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'isDone': false, 'streak': 0};
    }

    final userName = await _getUserName(user.uid);
    final doc = await FirebaseFirestore.instance
        .collection('habits')
        .doc('${userName}_${_dateString(date)}')
        .get();

    bool isDone = doc.exists && (doc.data()?['isDone'] == true);
    int streak = await _calculateStreak(userName, date);

    return {'isDone': isDone, 'streak': streak};
  }

  // Firestore에 해당 날짜 isDone값 설정
  Future<void> _setHabitDone(DateTime date, bool done) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userName = await _getUserName(user.uid);
    await FirebaseFirestore.instance
        .collection('habits')
        .doc('${userName}_${_dateString(date)}')
        .set({
      'userName': userName,
      'date': DateTime(date.year, date.month, date.day),
      'isDone': done,
    });
  }

  // 연속 일수 계산: 선택된 날짜로부터 과거로 거슬러 올라가며 done == true인 날을 센다.
  Future<int> _calculateStreak(String userName, DateTime date) async {
    int streakCount = 0;
    DateTime current = date;

    while (true) {
      final doc = await FirebaseFirestore.instance
          .collection('habits')
          .doc('${userName}_${_dateString(current)}')
          .get();

      if (doc.exists && (doc.data()?['isDone'] == true)) {
        streakCount++;
        // 이전 날로 이동
        current = current.subtract(const Duration(days: 1));
      } else {
        // done == false거나 문서 없으면 streak 중단
        break;
      }
    }

    return streakCount;
  }

  // UID로부터 userName 가져오는 함수 (예시용)
  Future<String> _getUserName(String uid) async {
    final userDoc = await FirebaseFirestore.instance.collection('user').doc(uid).get();
    return userDoc.data()?['userName'] ?? 'UnknownUser';
  }

  String _dateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
  }
}
