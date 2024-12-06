import 'package:flutter/material.dart';
import 'TaskManager.dart';
import 'Task.dart';
import 'AddPageGrid.dart'; // 새로 만든 그리드 위젯 import

class AddPageWork extends StatefulWidget {
  const AddPageWork({super.key, required this.selectedDay});
  final DateTime selectedDay;

  @override
  State<AddPageWork> createState() => _AddPageWorkState();
}

class _AddPageWorkState extends State<AddPageWork> {
  final TaskManager _taskManager = TaskManager();
  late DateTime _date;
  final _formKey = GlobalKey<FormState>();
  String _taskName = "";
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDay;
    // 초기값은 필요하다면 null로 두거나 기본값으로 설정
    _startTime = null;
    _endTime = null;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: '할 일 이름',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _taskName = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '할 일 이름을 입력해주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // 여기 시간 선택 대신 그리드 표시
            // 그리드를 통해 onTimeRangeSelected에서 _startTime과 _endTime 업데이트
            AddPageGrid(
              onTimeRangeSelected: (start, end) {
                setState(() {
                  _startTime = start;
                  _endTime = end;
                });
              },
            ),
            const SizedBox(height: 20),
            // 선택된 시간 표시
            Text(
              _startTime == null || _endTime == null
                  ? '시간을 선택해주세요 (최소 10분)'
                  : '시간: ${TimeOfDay.fromDateTime(_startTime!).format(context)} ~ ${TimeOfDay.fromDateTime(_endTime!).format(context)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('할일 추가'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('시간을 선택해주세요.')),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        final userId = await _taskManager.currentUserId;
        final task = Task(
          title: _taskName,
          date: _date,
          userId: userId,
          startTime: _startTime,
          endTime: _endTime,
        );
        await _taskManager.addTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('할 일이 추가되었습니다!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
