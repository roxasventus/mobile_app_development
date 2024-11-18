import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'SideMenu.dart';
import 'Tasks.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({Key? key}) : super(key: key);

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  int selectedTaskIndex = 0;

  // Grid data: 24 hours × 6 slots per hour = 144 intervals
  List<List<int?>> timetable = List.generate(24, (hour) => List.filled(6, null));

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<Tasks>(context);
    var now = DateTime.now();
    now = DateTime(now.year, now.month, now.day).toUtc();

    // Get tasks for the current date
    final List<String> tasks = tasksProvider.getTasks(now);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('오늘 할 일 리스트'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu), // 햄버거 버튼 아이콘 생성
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
          // Date Display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              DateFormat('MM월 dd일 EEEE', 'ko').format(now),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(40), // Fixed width for hour labels
                },
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  // Add Header Row
                  TableRow(
                    children: [
                      Container(
                        height: 40,
                        color: Colors.grey.shade300,
                        child: const Center(

                        ),
                      ),
                      ...List.generate(6, (interval) {
                        return Container(
                          height: 40,
                          color: Colors.grey.shade300,
                          child: Center(
                            child: Text(
                              '${(interval + 1) * 10}분',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  // Generate Timetable Rows
                  ...List.generate(24, (hour) {
                    return TableRow(
                      children: [
                        // Hour label
                        Container(
                          color: Colors.grey.shade200,
                          height: 40,
                          child: Center(
                            child: Text(
                              '$hour',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        // 10-minute intervals for the hour
                        ...List.generate(6, (interval) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                // Toggle activation state
                                if (timetable[hour][interval] == null) {
                                  timetable[hour][interval] = selectedTaskIndex; // Activate with current task
                                } else {
                                  timetable[hour][interval] = null; // Deactivate
                                }
                              });
                            },
                            child: Container(
                              height: 40,
                              color: timetable[hour][interval] != null
                                  ? Color(0xFFD3BCFD)
                                  : Colors.white,
                              child: Center(
                                child: timetable[hour][interval] != null
                                    ? Text(
                                  tasks[timetable[hour][interval]!], // Display task name
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                )
                                    : const Text(''),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Task Selection
          Expanded(
            flex: 1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTaskIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: selectedTaskIndex == index
                          ? Color(0xFFD3BCFD)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        tasks[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Add Task Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/Today/Add', arguments: now);
                },
                child: const Icon(Icons.edit),
              ),
              const SizedBox(width: 100.0),
              FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/Today');
                },
                child: const Icon(Icons.calendar_month),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
