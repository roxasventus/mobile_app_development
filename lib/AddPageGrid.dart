import 'package:flutter/material.dart';

class AddPageGrid extends StatefulWidget {
  final Function(DateTime start, DateTime end)? onTimeRangeSelected;

  const AddPageGrid({Key? key, this.onTimeRangeSelected}) : super(key: key);

  @override
  State<AddPageGrid> createState() => _AddPageGridState();
}

class _AddPageGridState extends State<AddPageGrid> {
  // 6~23시 (6부터 시작해서 18개 시간: 6,7,8,...,23)
  final hours = List.generate(18, (index) => 6 + index);
  // 0,10,20,30,40,50 분
  final minutes = [0, 10, 20, 30, 40, 50];

  DateTime? startTime;
  DateTime? endTime;

  // 선택 상태를 저장할 Map: key='row-col', value=true/false
  Map<String, bool> selectedCells = {};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // 필요한 경우 높이 조정
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
            // 시간별 행
            for (int r = 0; r < hours.length; r++)
              TableRow(
                children: [
                  SizedBox(
                    height: 30,
                    child: Center(child: Text('${hours[r]}시', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 20))),
                  ),
                  for (int c = 0; c < minutes.length; c++)
                    GestureDetector(
                      onTap: () {
                        _onCellTap(r, c);
                      },
                      child: Container(
                        height: 30,
                        color: _isCellSelected(r, c) ? Colors.blue.shade200 : Colors.white,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool _isCellSelected(int row, int col) {
    String key = '$row-$col';
    return selectedCells[key] == true;
  }

  void _onCellTap(int row, int col) {
    final h = hours[row];
    final m = minutes[col];
    final now = DateTime.now();
    final cellTime = DateTime(now.year, now.month, now.day, h, m);

    setState(() {
      if (startTime == null) {
        // 시작 시간 선택
        startTime = cellTime;
        endTime = null;
        selectedCells.clear();
        selectedCells['$row-$col'] = true;
      } else if (endTime == null) {
        // 종료 시간 선택
        if (cellTime.isBefore(startTime!)) {
          // 종료 시간이 시작 시간보다 이전이면 swap
          final temp = startTime;
          startTime = cellTime;
          endTime = temp;
        } else {
          endTime = cellTime;
        }

        // start~end 시간대 셀 하이라이트
        selectedCells.clear();
        _highlightRange();

        // 시간 범위 선택 완료 => 콜백 호출
        widget.onTimeRangeSelected?.call(startTime!, endTime!);
      } else {
        // 이미 start, end가 있다면 다시 start를 새로 지정
        startTime = cellTime;
        endTime = null;
        selectedCells.clear();
        selectedCells['$row-$col'] = true;
      }
    });
  }

  void _highlightRange() {
    if (startTime == null || endTime == null) return;

    // startTime, endTime 사이 모든 셀을 선택
    final start = _timeToIndex(startTime!);
    final end = _timeToIndex(endTime!);

    int startIndex = start.row * minutes.length + start.col;
    int endIndex = end.row * minutes.length + end.col;

    if (endIndex < startIndex) {
      final temp = startIndex;
      startIndex = endIndex;
      endIndex = temp;
    }

    for (int i = startIndex; i <= endIndex; i++) {
      int r = i ~/ minutes.length;
      int c = i % minutes.length;
      selectedCells['$r-$c'] = true;
    }
  }

  // 시간 -> 인덱스로 변환하는 함수
  _TimeIndex _timeToIndex(DateTime t) {
    final hIndex = hours.indexOf(t.hour);
    final mIndex = minutes.indexOf(t.minute);
    return _TimeIndex(hIndex, mIndex);
  }
}

class _TimeIndex {
  final int row;
  final int col;
  _TimeIndex(this.row, this.col);
}
