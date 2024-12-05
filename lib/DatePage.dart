// lib/DatePage.dart
import 'package:appproject/AddPage.dart';
import 'package:appproject/TodayPage.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'Task.dart';
import 'TaskManager.dart';
import 'SideMenu.dart';

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('날짜별 할 일 리스트'),
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
      body: Center(
        child: Column(
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
                if (!mounted) return;
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
        // StreamBuilder를 사용한다고 가정 (이미 구현됨)
        return StreamBuilder<List<Task>>(
          stream: _taskManager.getTasksByDateStream(selectedDay),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('작업을 불러오는 중 오류가 발생했습니다.')),
              );
            }

            final tasks = snapshot.data ?? [];

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(selectedDay),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  if (tasks.isEmpty)
                    const Text(
                      '할 일이 없습니다.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (bool? value) async {
                                await _taskManager.toggleTaskCompletion(task.id, task.isCompleted);
                                // StreamBuilder -> 자동 반영
                              },
                            ),
                            title: Text(task.title),
                            // 여기서 시작시간 ~ 끝시간 표시
                            subtitle: (task.startTime != null && task.endTime != null)
                                ? Text(
                              '시작: ${TimeOfDay.fromDateTime(task.startTime!).format(context)} - 끝: ${TimeOfDay.fromDateTime(task.endTime!).format(context)}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            )
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _taskManager.deleteTask(task.id);
                                // StreamBuilder -> 자동 반영
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPage(selectedDay: selectedDay),
                            ),
                          );
                        },
                        child: const Icon(Icons.edit),
                      ),
                      const SizedBox(width: 100.0),
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => TodayPage()),
                          );
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
}
