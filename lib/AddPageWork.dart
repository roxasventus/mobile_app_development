import 'package:flutter/material.dart';
import 'TaskManager.dart';
import 'Task.dart';
import 'package:intl/intl.dart';

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
    _startTime = DateTime(_date.year, _date.month, _date.day, 0, 0);
    _endTime = _startTime!.add(const Duration(minutes: 10));
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '시작: ${TimeOfDay.fromDateTime(_startTime!).format(context)}',
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_startTime!),
                );
                if (picked != null) {
                  setState(() {
                    _startTime = DateTime(_date.year, _date.month,
                        _date.day, picked.hour, picked.minute);
                  });
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '끝: ${TimeOfDay.fromDateTime(_endTime!).format(context)}',
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_endTime!),
                );
                if (picked != null) {
                  setState(() {
                    _endTime = DateTime(_date.year, _date.month,
                        _date.day, picked.hour, picked.minute);
                  });
                }
              },
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
