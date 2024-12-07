// DatePage.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'TaskManager.dart';
import 'SideMenu.dart';
import 'DatePageTab.dart';
import 'BackgroundContainer.dart'; // BackgroundContainer 임포트 추가
import 'MemorizeView.dart';

class DatePage extends StatefulWidget {
  const DatePage({super.key});

  @override
  State<DatePage> createState() => _DatePageState();
}

class _DatePageState extends State<DatePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TaskManager _taskManager = TaskManager();

  @override
  Widget build(BuildContext context) {
    String dayOfWeek = DateFormat('EEE').format(_focusedDay);
    String formattedDate = DateFormat('MMM d').format(_focusedDay);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/topbar_background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: const Text('날짜별 할 일 리스트', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 30)),
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
        imagePath: 'assets/images/background.png', // 배경 이미지 경로 추가
        child: Column(
          children: [
            // 상단 콘텐츠를 Expanded로 감싸서 남는 공간을 채움
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '$dayOfWeek, $formattedDate',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _showTasksBottomSheet(selectedDay);
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
                        todayTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        selectedDecoration: const BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                        defaultDecoration: const BoxDecoration(shape: BoxShape.circle),
                        weekendDecoration: const BoxDecoration(shape: BoxShape.circle),
                        outsideDaysVisible: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 여기서 MemorizeView를 하단에 붙이는 컨테이너
            Container(
              height: MediaQuery.of(context).size.height * 0.1, // 화면 높이의 10%
              child: const MemorizeView(),
            ),
          ],
        ),
      ),
    );
  }

  void _showTasksBottomSheet(DateTime selectedDay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.purple.shade50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DatePageTab(
          selectedDay: selectedDay,
          taskManager: _taskManager,
          refreshTasks: (DateTime date) {
            setState(() {}); // 간단한 UI 새로고침
          },
        );
      },
    );
  }
}
