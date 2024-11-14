import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receive User Information',
      theme: ThemeData(
        primaryColor: Colors.blue,
        primarySwatch: Colors.orange,
        fontFamily: 'Pretendard',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> task = ['task1', 'task2', 'task3', 'task4'];
  int selectedValue = 0;
  List<List<int?>> timetable = List.generate(12, (index) => List.filled(7, null)); // 시간표의 상태를 나타내는 리스트

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
                children:
                  List.generate(13, (row) {

                  /*
                  if( row == 0 ) {
                    return TableRow(
                      children: List.generate(7, (time){
                        return Container(
                          height: 30,
                          width: 30,
                          child: Text('$time+1'),
                        );
                      })
                    );
                  }

                  */
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
