import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'SideMenu.dart';
import 'Tasks.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  @override
  Widget build(BuildContext context) {
    final date = ModalRoute.of(context)?.settings.arguments as DateTime;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("할 일 추가"),
          bottom: const TabBar(
            tabs: [
              Tab(text: '할 일'),
              Tab(text: '미완성'),
              Tab(text: '과거기록'),
            ],
          ),
          leading: Builder(
              builder: (context){
                return IconButton(
                  icon: Icon(Icons.menu), // 햄버거버튼 아이콘 생성
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              }
          ),
        ),
        drawer: SideMenu(),
        body: TabBarView(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                MyForm(),
                const SizedBox(height: 10),
                Expanded(
                  flex: 2,
                  child: Consumer<Tasks>(
                    builder: (context, tasksProvider, _) {
                      return ReorderableTaskList(tasks: tasksProvider.taskList, date: date);
                    },
                  ),
                ),

              ],
            ),
            Center(child: Text('미완성')),
            Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Consumer<Tasks>(
                    builder: (context, tasksProvider, _) {
                      return ReorderableTaskList(tasks: tasksProvider.pasttaskList, date: date);
                    },
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}


class MyForm extends StatefulWidget {
  const MyForm({Key? key}) : super(key: key);

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  String taskName = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Task Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    taskName = value ?? "";
                  },
                ),
              ),
              const SizedBox(width: 10), // Add some spacing between the text field and button
              GestureDetector(
                child: Container(
                  width: 80,  // Fixed width for the Enter button
                  height: 50,
                  color: Colors.deepPurple,
                  alignment: Alignment.center,
                  child: const Text(
                    '+',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Provider.of<Tasks>(context, listen: false).addToTaskList(taskName);
                    Provider.of<Tasks>(context, listen: false).addToPastTaskList(taskName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task added to list!')),
                    );
                    setState(() {}); // Refresh the UI if needed
                  }
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}


class ReorderableTaskList extends StatefulWidget {
  final List<String> tasks;
  final DateTime date;

  const ReorderableTaskList({Key? key, required this.tasks, required this.date}) : super(key: key);

  @override
  _ReorderableTaskListState createState() => _ReorderableTaskListState();
}

class _ReorderableTaskListState extends State<ReorderableTaskList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: widget.tasks.length,
      itemBuilder: (c, i) {
        return Dismissible(
          key: ValueKey(widget.tasks[i]),
          child: ListTile(
            title: Text(widget.tasks[i]),
            leading: const Icon(Icons.task),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              _onTaskClick(widget.tasks[i]);
            },
          ),
          onDismissed: (direction) {
            setState(() {
              widget.tasks.removeAt(i);
            });
          },
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) newIndex -= 1;
          final item = widget.tasks.removeAt(oldIndex);
          widget.tasks.insert(newIndex, item);
        });
      },
    );
  }

  void _onTaskClick(String task) {
    Provider.of<Tasks>(context, listen: false).addTask(widget.date, task);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "$task" added to date ${widget.date.toString().split(' ')[0]}!')),
    );

    setState(() {}); // Refresh the UI if needed
  }
}