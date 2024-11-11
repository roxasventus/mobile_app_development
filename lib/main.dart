import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// 할 일 목록
final Map<DateTime, List<String>> _tasks = {
  //DateTime(2024, 11, 17): ['Task 1', 'Task 2', 'Task 3'],
  //DateTime(2024, 11, 18): ['Task 4', 'Task 5'],
};


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/Today': (context) => const DatePage(),
        '/Today/Add': (context) => const AddPage(),
      },
    );
  }
}

// MyHomePage //////////////////////////////////////
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text('오늘의 할 일 리스트'),
        leading: IconButton(
          icon: Icon(Icons.menu), // 햄버거버튼 아이콘 생성
          onPressed: () {
            // 아이콘 버튼 실행
            print('menu button is clicked');
          },
        ),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, '/Today');
        },
        tooltip: 'Increment',
        child: const Icon(Icons.calendar_month),
      ),
    );
  }
}
//////////////////////////////////////////////////////


// DatePage //////////////////////////////////////
class DatePage extends StatefulWidget {
  const DatePage({super.key});

  @override
  State<DatePage> createState() => _DatePageState();
}

class _DatePageState extends State<DatePage> {
  int _counter = 0;
  // 첫 빌드시, 달력에서 자동으로 보여줄 날이 포함된 영역
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    // 선택된 날짜의 요일과 월을 원하는 형식으로 가져옵니다.
    String dayOfWeek = DateFormat('EEE').format(_focusedDay); // 요일 (Mon, Tue 등)
    String formattedDate = DateFormat('MMM d').format(_focusedDay); // 월과 일 (Aug 17 등)

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text('날짜별 할 일 리스트'),
        leading: IconButton(
          icon: Icon(Icons.menu), // 햄버거버튼 아이콘 생성
          onPressed: () {
            // 아이콘 버튼 실행
            print('menu button is clicked');
          },
        ),
      ),
      body: Center(

        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '$dayOfWeek, $formattedDate', // 요일과 월+날짜 표시
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            TableCalendar(
              // 달력 구성시, 맨 처음 보여줄 날짜
              firstDay: DateTime.utc(2020, 1, 1),
              // 달력 구성시, 맨 마지막 보여줄 날짜
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              // 특정 날짜가 선택된 날짜인지 여부를 정의하는 데 사용된다.
              // 이를 통해 선택된 날짜를 시각적으로 강조할 수 있다.
              // isSameDay 함수를 이용해 현재 선택된 날짜와 달력의 날짜가 같은지 비교
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update focusedDay when the user taps a day
                });
                _showTasksBottomSheet(selectedDay); // 날짜 선택 시 BottomSheet 표시
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple.shade100,width: 1.5)
                ),
                todayTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
            ),
          ],
        ),
      ),

    );
  }
// 선택된 날짜의 할 일을 표시하는 BottomSheet
  void _showTasksBottomSheet(DateTime selectedDay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.purple.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // Convert List<String> to List<Task>
        List<Task> tasks = (_tasks[selectedDay] ?? []).map((taskName) => Task(taskName, selectedDay)).toList();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              Text(
                DateFormat('MMM d, yyyy').format(selectedDay),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              ...tasks.map((task) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.shade100,
                  child: Icon(Icons.task, color: Colors.purple),
                ),
                title: Text(task.name),
                trailing: Checkbox(
                  value: false,
                  onChanged: (bool? value) {},
                ),
              )),
              if (tasks.isEmpty)
                Text('할 일이 없습니다.', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/Today/Add', arguments: selectedDay);
                    },
                    child: const Icon(Icons.edit),
                  ),
                  SizedBox(width: 100.0),
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.format_list_bulleted),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// AddPage //////////////////////////////////////
class AddPage extends StatefulWidget {
  const AddPage({super.key});


  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  List<Task> tasks = [];

  void addTask(Task task) {
    setState(() {
      if (_tasks[task.date] == null) {
        _tasks[task.date!] = [];
      }
      _tasks[task.date]!.add(task.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final date = ModalRoute.of(context)?.settings.arguments as DateTime;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("할 일 추가"),

          bottom: const TabBar(
            tabs: [
              Tab(text: '할 일'),
              Tab(text: '미완성'),
              Tab(text: '과거기록'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 첫 번째 탭에 MyForm과 ReorderableStudentList를 함께 배치
            Column(
              children: [
                Expanded(
                  flex: 3,
                  child: MyForm(onSubmit: addTask, date: date),
                ),
                Expanded(
                  flex: 2,
                  child: ReorderableTaskList(task: tasks),
                ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back),
                ),
              ],
            ),
            // 나머지 탭들은 이전과 동일하게 유지
            Center(child: Text('미완성')),
            Center(child: Text('과거기록')),
          ],
        ),
      ),
    );
  }
}
////////////////////////////////////////////////////

class MyForm extends StatefulWidget {
  final Function(Task) onSubmit;
  final DateTime date;

  const MyForm({Key? key, required this.onSubmit, required this.date}) : super(key: key);

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  Task task = Task("", null);
  final _formKey = GlobalKey<FormState>();

  // Helper function to gather all task names from _tasks
  List<String> _getAllTasks() {
    return _tasks.values.expand((taskList) => taskList).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Task Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text.';
              } else if (int.tryParse(value) != null) {
                return 'Please enter text, not a number.';
              }
              return null;
            },
            onSaved: (value) {
              task.name = value ?? "";
              task.date = widget.date;
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              child: Container(
                width: 400,
                height: 50,
                color: Colors.indigo,
                alignment: Alignment.center,
                child: const Text(
                  'Enter',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.onSubmit(task); // Add task
                  task = Task('', null); // Reset task input
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task added!'),
                    ),
                  );
                  setState(() {}); // Refresh to display the updated task list
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const Text(
            'All Registered Tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: _getAllTasks().isNotEmpty
                ? ListView.builder(
              itemCount: _getAllTasks().length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_getAllTasks()[index]),
                  leading: const Icon(Icons.task),
                );
              },
            )
                : const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No tasks registered yet.', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}



class ReorderableTaskList extends StatefulWidget {
  final List<Task> task;

  const ReorderableTaskList({Key? key, required this.task})
      : super(key: key);

  @override
  _ReorderableTaskListState createState() =>
      _ReorderableTaskListState();
}

class _ReorderableTaskListState extends State<ReorderableTaskList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: widget.task.length,
      itemBuilder: (c, i) {
        return Dismissible(
          background: Container(color: Colors.green),
          key: ValueKey(widget.task[i]),
          child: ListTile(
            title: Text(
                '${widget.task[i].name}: ${widget.task[i].date}'),
            leading: const Icon(Icons.home),
            trailing: const Icon(Icons.navigate_next),
          ),
          onDismissed: (direction) {
            setState(() {
              widget.task.removeAt(i);
            });
          },
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) newIndex -= 1;
          widget.task.insert(newIndex,
              widget.task.removeAt(oldIndex));
        });
      },
    );
  }
}

class Task {
  String name;
  DateTime? date;

  Task(this.name, this.date);

  @override
  String toString() {
    return '($name, ${date != null ? date.toString() : 'No date'})';
  }
}