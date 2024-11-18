import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'SideMenu.dart';
import 'Tasks.dart';

class DatePage extends StatefulWidget {
  const DatePage({super.key});

  @override
  State<DatePage> createState() => _DatePageState();
}

class _DatePageState extends State<DatePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    String dayOfWeek = DateFormat('EEE').format(_focusedDay);
    String formattedDate = DateFormat('MMM d').format(_focusedDay);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('날짜별 할 일 리스트'),
        leading: Builder(
            builder: (context){
              return IconButton(
                icon: Icon(Icons.menu), // 햄버거버튼 아이콘 생성
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            }
        ),
      ),
      drawer: SideMenu(),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '$dayOfWeek, $formattedDate',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showTasksBottomSheet(selectedDay); // Show tasks when a day is selected
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.purple.shade100, width: 1.5),
                ),
                todayTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                selectedDecoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                defaultDecoration: BoxDecoration(shape: BoxShape.circle),
                weekendDecoration: BoxDecoration(shape: BoxShape.circle),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final tasks = Provider.of<Tasks>(context).getTasks(selectedDay) ?? [];
        final Map<String, bool> taskCompletion = {
          for (var task in tasks) task: false,
        };

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(selectedDay),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  ...tasks.map((task) {
                    return CheckboxListTile(
                      value: taskCompletion[task],
                      onChanged: (bool? value) {
                        setState(() {
                          taskCompletion[task] = value ?? false;
                        });
                      },
                      title: Text(task),
                      secondary: CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: Icon(Icons.task, color: Colors.purple),
                      ),
                    );
                  }),
                  if (tasks.isEmpty)
                    Text('할 일이 없습니다.', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/Today/Add', arguments: selectedDay);
                        },
                        child: const Icon(Icons.edit),
                      ),
                      SizedBox(width: 100.0),
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
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
