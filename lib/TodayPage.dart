import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({Key? key}) : super(key: key);

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final List<String> task = ['task1', 'task2', 'task3', 'task4'];
  int selectedValue = 0;

  // Updated timetable size to 13 rows
  List<List<int?>> timetable = List.generate(13, (index) => List.filled(7, null));

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('오늘 할 일 리스트'),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.menu),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              DateFormat('MM월 dd일 EEEE', 'ko').format(now),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20), // 상단 날짜와 다른 위젯 간의 여백
            // 시간표 부분
            Flexible(
              flex: 3,
              child: Table(
                border: TableBorder.all(),
                children: List.generate(13, (row) {
                  return TableRow(
                    children: List.generate(7, (col) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            timetable[row][col] = selectedValue; // 선택된 Task 번호를 해당 셀에 할당
                          });
                        },
                        child: Container(
                          height: 30,
                          color: timetable[row][col] != null ? Colors.orangeAccent : Colors.white,
                          child: Center(
                            child: timetable[row][col] != null
                                ? Text('Task ${timetable[row][col]! + 1}')
                                : Text(''),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
            SizedBox(height: 20), // 시간표와 리스트 간의 여백
            // Task 리스트 부분
            Flexible(
              flex: 2,
              child: ListView.builder(
                itemCount: task.length,
                itemBuilder: (context, index) {
                  return RadioListTile<int>(
                    key: ValueKey(task[index]),
                    title: Text(task[index]),
                    value: index,
                    groupValue: selectedValue,
                    onChanged: (int? value) {
                      setState(() {
                        selectedValue = value!;
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20), // 리스트와 버튼 간의 여백
            // 버튼 부분
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      task.add('Task ${task.length + 1}');
                    });
                  },
                  child: const Icon(Icons.edit),
                ),
                FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.format_list_bulleted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
