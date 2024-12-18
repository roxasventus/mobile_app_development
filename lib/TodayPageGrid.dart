import 'package:flutter/material.dart';
import 'Task.dart'; // Task 모델 import 필요

class TodayPageGrid extends StatelessWidget {
  final List<Task> tasks;

  const TodayPageGrid({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 시간 범위: 6~23시, 10분 단위
    final hours = List.generate(18, (index) => 6 + index);  // 6,7,...,23
    final minutes = [0, 10, 20, 30, 40, 50];

    // 한 셀에 여러 개의 Task 저장
    Map<String, List<Task>> cellTaskMap = {};

    // 색상 리스트 (Task별 구분)
    final colorList = [
      Colors.green.shade300,
      Colors.pink.shade200,
      Colors.yellow.shade300,
      Colors.orange.shade300,
      Colors.purple.shade200,
      Colors.lightBlue.shade200,
      Colors.teal.shade300,
      Colors.brown.shade300,
    ];

    // 각 할 일마다 고유 색상 할당
    // 여기서 task.id를 키로 쓰고, colorList에서 순서대로 색 할당
    final Map<String, Color> taskColorMap = {};
    for (int i = 0; i < tasks.length; i++) {
      final t = tasks[i];
      taskColorMap[t.id] = colorList[i % colorList.length];
    }

    DateTime roundDownTo10Min(DateTime dt) {
      int roundedMinute = (dt.minute ~/ 10) * 10;
      return DateTime(dt.year, dt.month, dt.day, dt.hour, roundedMinute);
    }

    Map<String, int>? timeToRowCol(DateTime t) {
      final h = t.hour;
      final m = t.minute;
      if (h < 6 || h > 23) return null;
      if (!minutes.contains(m)) return null;
      final rowIndex = hours.indexOf(h);
      final colIndex = minutes.indexOf(m);
      if (rowIndex == -1 || colIndex == -1) return null;
      return {'row': rowIndex, 'col': colIndex};
    }

    // 각 Task에 대해 startTime~endTime 구간의 모든 10분 블록에 Task를 추가
    for (int i = 0; i < tasks.length; i++) {
      final t = tasks[i];
      if (t.startTime == null || t.endTime == null) continue;
      final st = t.startTime!;
      final et = t.endTime!;

      DateTime current = roundDownTo10Min(st);
      while (current.isBefore(et)) {
        final pos = timeToRowCol(current);
        if (pos != null) {
          String key = '${pos['row']!+1}-${pos['col']!+1}';
          cellTaskMap.putIfAbsent(key, () => []);
          cellTaskMap[key]!.add(t);
        }
        current = current.add(const Duration(minutes: 10));
      }
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
          border: TableBorder.all(color: Colors.grey),
          children: [
            // 헤더 행
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Center(child: Text('시간', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 20))),
                ),
                for (var m in minutes)
                  SizedBox(
                    height: 30,
                    child: Center(child: Text('$m분', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 20))),
                  ),
              ],
            ),
            // 나머지 시간 행들
            for (int row = 0; row < hours.length; row++)
              TableRow(
                children: [
                  SizedBox(
                    height: 30,
                    child: Center(child: Text('${hours[row]}시', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 20))),
                  ),
                  for (int col = 0; col < minutes.length; col++)
                    Builder(
                      builder: (context) {
                        String key = '${row+1}-${col+1}';
                        List<Task>? cellTasks = cellTaskMap[key];

                        if (cellTasks == null || cellTasks.isEmpty) {
                          // 해당 셀에 할일 없음
                          return Container(
                            height: 30,
                            color: Colors.white,
                          );
                        } else {
                          // 최대 3개만 렌더링
                          const maxDisplay = 3;
                          List<Task> displayedTasks = cellTasks.take(maxDisplay).toList();

                          return Container(
                            height: 30,
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final task in displayedTasks)
                                  Container(
                                    height: 5,
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(vertical: 1.0),
                                    // 여기서 task별로 미리 할당한 색상 사용
                                    color: taskColorMap[task.id],
                                  ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
