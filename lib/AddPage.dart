// lib/AddPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'TaskProvider.dart';
import 'task.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AddPage extends StatefulWidget {
  final DateTime? selectedDate;

  const AddPage({Key? key, this.selectedDate}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.selectedDate != null) {
      _date = widget.selectedDate!;
    }
  }

  Future<void> _addTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Task newTask = Task(
        title: _title,
        description: _description,
        date: _date,
      );
      Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 할 일 추가'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '제목'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '설명'),
                onSaved: (value) {
                  _description = value ?? '';
                },
              ),
              Row(
                children: [
                  const Text('날짜: '),
                  Text(DateFormat('yyyy-MM-dd').format(_date)),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null && picked != _date) {
                        setState(() {
                          _date = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTask,
                child: const Text('추가'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
