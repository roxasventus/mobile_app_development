import 'package:flutter/material.dart';
import 'main.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class FeedBackPage extends StatefulWidget {
  const FeedBackPage({super.key});

  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  int weekOfYear = 1; // 초기 주차 설정
  DateTime selectedDate = DateTime.utc(
    DateTime
        .now()
        .year,
    DateTime
        .now()
        .month,
    DateTime
        .now()
        .day,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text('날짜 단위 피드백'),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.menu),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.logout),
          ),
        ],
      ),
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
                weekOfYear = _calculateWeekOfYear(selectedDay);
              });
            },
          ),
          Container(
            height: 50,
            color: Colors.red.shade100,
            alignment: Alignment.center,
            child: Text(
              '${selectedDate.month}월 간 달성률 : 100%',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Container(
            height: 50,
            color: Colors.blue.shade100,
            alignment: Alignment.center,
            child: Text(
              '${selectedDate.month}월 ${weekOfYear}주 간 달성률 : 100%',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Container(
            height: 50,
            color: Colors.green.shade100,
            alignment: Alignment.center,
            child: Text(
              '${selectedDate.month}/${selectedDate.day} 일간 달성률 : 100%',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Container(
            height: 50,
          )
        ],
      ),
    );
  }

  int _calculateWeekOfYear(DateTime date) {
    // 해당 월의 첫 번째 날을 기준으로 주차 계산
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    int dayOfMonth = date.day;
    int firstWeekday = firstDayOfMonth.weekday;

    // 첫째 주의 남은 날 + 현재 날짜까지의 차이를 7로 나누어 주차 계산
    return ((dayOfMonth + firstWeekday - 1) / 7).ceil();
  }

}