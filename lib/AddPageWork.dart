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
                        // 여기서 이미 10분 단위 선택 로직이 있다고 가정
                      );
                      if (picked != null) {
                        setState(() {
                          _startTime = DateTime(
                            _date.year,
                            _date.month,
                            _date.day,
                            picked.hour,
                            picked.minute,
                          );
                          // 시작시간 설정 후 끝시간은 자동으로 10분 후
                          _endTime =
                              _startTime!.add(const Duration(minutes: 10));
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
                        // 여기서 이미 10분 단위 선택 로직이 있다고 가정
                      );
                      if (picked != null) {
                        DateTime chosenEndTime = DateTime(
                          _date.year,
                          _date.month,
                          _date.day,
                          picked.hour,
                          picked.minute,
                        );
                        setState(() {
                          // 만약 사용자가 시작시간+10분 이전을 선택한다면 시작시간+10분으로 맞추고 경고 메시지
                          if (chosenEndTime.isBefore(
                              _startTime!.add(const Duration(minutes: 10)))) {
                            chosenEndTime =
                                _startTime!.add(const Duration(minutes: 10));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      '끝나는 시간은 시작시간으로부터 최소 10분 이후여야 합니다.')),
                            );
                          }
                          _endTime = chosenEndTime;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addTask,
                    child: const Text('할일 추가'),
                  ),
                  Container(
                    height: 50,
                  ),
                  Container(
                      child: Text(
                    '작업의 최소 시간은 10분이며, 시간은 자동으로 10분 단위로 선택됩니다.',
                    style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                  ))
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
