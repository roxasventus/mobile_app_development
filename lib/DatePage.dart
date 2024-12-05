// lib/DatePage.dart
import 'package:appproject/AddPage.dart';
import 'package:appproject/TodayPage.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _showTasksBottomSheet(selectedDay);
                }
              },
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.purple.shade100, width: 1.5),
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
        return FutureBuilder<List<Task>>(
          future: _taskManager.getTasksByDate(selectedDay),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 드래그 핸들러
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  // 선택한 날짜 표시
                  Text(
                    DateFormat('MMM d, yyyy').format(selectedDay),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  // 할 일 목록 또는 빈 상태 메시지
                  if (tasks.isEmpty)
                    const Text(
                      '할 일이 없습니다.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple.shade100,
                            child: const Icon(Icons.task, color: Colors.purple),
                          ),
                          title: Text(task.title),
                          subtitle: task.startTime != null && task.endTime != null
                              ? Text(
                            'Start: ${TimeOfDay.fromDateTime(task.startTime!).format(context)} - End: ${TimeOfDay.fromDateTime(task.endTime!).format(context)}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddPage(selectedDay: selectedDay),
                                    ),
                                  ).then((_) {
                                    // 할 일 추가 후 리스트 새로 고침
                                    setState(() {});
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.list),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const TodayPage()),
                                  );
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            // 할 일 수정 기능을 추가할 수 있습니다.
                          },
                          onLongPress: () {
                            // 할 일 삭제 기능
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('할 일 삭제'),
                                content: const Text('정말로 이 할 일을 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _taskManager.deleteTask(task.id);
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: const Text('삭제'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 16.0),
                  // 좌우 버튼 (플러스 & 리스트)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'addButton',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPage(selectedDay: selectedDay),
                            ),
                          ).then((_) {
                            // 할 일 추가 후 리스트 새로 고침
                            setState(() {});
                          });
                        },
                        child: const Icon(Icons.add),
                      ),
                      FloatingActionButton(
                        heroTag: 'listButton',
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const TodayPage()),
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
