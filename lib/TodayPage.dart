
//구글폼 같은 거



import 'package:flutter/material.dart';
import 'dart:math';

// -- 2024_11_10 00:27 날짜 띄우기
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // 여기서 initializeDateFormatting 가져옴

// --

enum Language {cpp, python, dart}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko'); // 'ko' 로케일 초기화
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

      //여기부터 home 대신
      initialRoute: '/',
      routes: {
        '/' :(context) =>  const MyHomePage(),
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

  List items = List.generate(20, (i) => i );
  final _midController = TextEditingController();
  final _finalController = TextEditingController();
  //List<String> _valueList = ['0','1','2','3','4','5','6','7','8','9'];
  final _valueList = List.generate(10, (i) => i);
  // bool _isChecked = false;
  // var _selectState = 0;
  // int _additionalPoint = 0;
  // int _leaderPoint = 0;

  // String _grade = 'F';


  void dispose(){
    _midController.dispose();
    _finalController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context){


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('오늘 할 일 리스트'),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.menu),
        ),
      ),

      body: TodayPage(),
    );
  }
}

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {

  String grade = '';
  final _valueList = List.generate(10, (i) => i);
  final _formKey = GlobalKey<FormState>();
  var now = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('MM월 dd일 EEEE', 'ko').format(now),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Table(
                border: TableBorder.all(),
                children: [
                  TableRow(
                    children: [
                      Container(
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('10'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('20'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('30'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('40'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('50'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('60'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('10'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('20'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('30'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('40'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('50'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('60'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('10'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('20'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('30'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('40'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('50'),
                        height: 20,
                        color: Colors.blue,
                      ),
                      Container(
                        child: Text('60'),
                        height: 20,
                        color: Colors.blue,
                      ),

                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('6', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('13', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('20', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),

                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('7', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('14', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('21', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),

                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('8', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('15', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('22', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),

                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('9', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('16', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('23', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),

                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('10', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('17', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('24', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),

                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('11', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('18', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('1', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),

                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('12', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('19', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.orange,
                        child: Text('2', style:
                        TextStyle(fontSize: 15),textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),

                    ],
                  ),

                ],
              ),

              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Task1'),
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Task2'),
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Task3'),
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Task4'),
              ),ListTile(
                leading: Icon(Icons.edit),
                title: Text('Task5'),
              ),



              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FloatingActionButton(
                      onPressed: () {

                      },
                      child: const Icon(Icons.edit),
                    ),
                    FloatingActionButton(
                      onPressed: () {

                      },
                      child: const Icon(Icons.format_list_bulleted),
                    ),]
              ),
            ],
          ),

        )
    );
  }
}

//새로운 페이지

