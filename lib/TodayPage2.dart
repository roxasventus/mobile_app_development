
//2024_11_15 02:33 시간표 클릭시 번호 출력



import 'package:flutter/material.dart';

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
        backgroundColor: Colors.purple.shade100,
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

  int selectedValue = 0 ;
  List<String> task = ['task1', 'task2','Task2','Task4'];
  List<int?> location = List.generate(4, (index) => 0);
  int _start_location = 0;
  int _end_location = 0;
  int _change_col = 6;
  int _change_row = 0;
  final _valueList = List.generate(10, (i) => i);
  final _formKey = GlobalKey<FormState>();
  int _start_end = 0 ;

  List<Color> colorList = [

    Colors.greenAccent.shade100,
    Colors.pink.shade50,
    Colors.yellow.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.lightBlueAccent.shade100,
  ];


  List<List<int?>> timetable = List.generate(25, (index) => List.filled(7, null));
  List<List<Color?>> colortable = List.generate(25, (index) => List.filled(7, Colors.white));

  var now = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade600, // 경계선 색상
                    width: 3, // 경계선 두께
                  ),
                  color: Colors.yellowAccent.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: 300,
                  height: 30,
                  child: Text(
                    DateFormat('MM월 dd일 EEEE', 'ko').format(now),
                    style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // 경계선 색상
                      width: 3, // 경계선 두께
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: SizedBox(
                    width: 400,
                    height: 300,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Flexible(
                        flex: 3,
                        child: Table(
                          border: TableBorder.all(),
                          children: List.generate(25, (row) {

                            if( row == 0 ) {
                              return TableRow(
                                  children: List.generate(7, (time){
                                    return Container(

                                      color: Colors.lightBlue.shade100,
                                      height: 30,
                                      width: 30,
                                      child: time == 0
                                          ?Text('')
                                          :Text('$time',style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                                    );
                                  })
                              );
                            }
                            else {return TableRow(
                              children: List.generate(7, (col) {
                                if ( col == 0 ) {
                                  return Container(

                                    color: Colors.lightBlue.shade100,
                                    height: 30,
                                    width: 30,
                                    child: row == 0
                                        ?Text('')
                                        :Text('${ (row + 5) % 24 }',style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                                  );
                                }
                                return GestureDetector(
                                  onLongPress: (){
                                    setState(() {

                                      print('LongPress ${row} , ${col} _start_end: ${_start_end}');

                                      if (_start_end == 0) {
                                        print('if');
                                        _start_end = 1;
                                        location[0] = row;
                                        location[1] = col;
                                      }
                                      else{
                                        print('else');
                                        _start_end = 0;
                                        location[2] = row;
                                        location[3] = col;
                                        _start_location = (location[0]!-1)*6 + location[1]!;
                                        _end_location = (location[2]!-1)*6 + location[3]!;

                                        if(_end_location < _start_location) {
                                          print('swap before ${_end_location} , ${_start_location} _start_end: ${_start_end}');
                                          int temp = _end_location;
                                          _end_location = _start_location;
                                          _start_location = temp;
                                          print('swap after ${_end_location} , ${_start_location} _start_end: ${_start_end}');
                                        }

                                        while (_start_location <= _end_location){

                                          _start_location%6 == 0
                                              ? _change_col = 6
                                              : _change_col = _start_location%6;

                                          _change_col == 6
                                          ? _change_row = _start_location~/6
                                          : _change_row = _start_location~/6 + 1;

                                          print('ValueChanged ${_change_row} , ${_change_col}');

                                          (timetable[_change_row][_change_col] == selectedValue)
                                              ? timetable[_change_row ][_change_col] = null
                                              :timetable[_change_row][_change_col] = selectedValue;
                                          _start_location += 1;

                                          (colortable[_change_row][_change_col] == selectedValue)
                                              ? colortable[_change_row ][_change_col] = Colors.white
                                              :colortable[_change_row][_change_col] = colorList[selectedValue%6];
                                        }




                                        location = [0,0,0,0];
                                      }

                                    });
                                  },
                                  /*
                                  onPanUpdate: (detail){
                                    setState(() {
                                      location[2] = row;
                                      location[3] = col;

                                      print('is PanUpdate ${row}, ${col}');

                                    });
                                  },
                                  */

                                  onTap: () {
                                    setState(() {

                                      ((timetable[row][col] == null) | (timetable[row][col] != selectedValue))
                                          ?timetable[row][col] = selectedValue
                                          : timetable[row][col] = null; // 선택된 Task 번호를 해당 셀에 할당

                                      (timetable[row][col] == null)
                                          ? colortable[row][col] = Colors.white
                                          :colortable[row][col] = colorList[selectedValue%6];

                                      print('onTap ${row} , ${col} ');
                                    });
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,

                                    decoration: BoxDecoration(

                                      color: (timetable[row][col] != null) || ( (row == 0 ) || ( col == 0 ) )
                                          ? colortable[row][col] : Colors.white,
                                      border: ((location[0] == row) & (location[1] == col))
                                          ? Border.all(
                                        color: Colors.red,  // 조건이 참일 때 빨간색 테두리
                                        width: 5,
                                      )
                                          : Border.all(
                                        color: Colors.grey.shade300,  // 조건이 거짓일 때 검은색 테두리
                                        width: 2.5,
                                      ),
                                      //borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: timetable[row][col] != null
                                          ? Text('${timetable[row][col]! + 1}',style: TextStyle(fontSize: 20),textAlign: TextAlign.center,)
                                          : Text(''),
                                    ),
                                  ),
                                );
                              }),
                            );}
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),



              /*
              GestureDetector(
                onTap: (){
                  setState(() {
                    print('Click');
                  });
                },
                onLongPress:  (){
                  setState(() {
                    print('press');
                  });
                },
                child:
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
              ),
              */


              Flexible(
                child: ListView.builder(
                  itemCount: task.length,
                  itemBuilder: (context, index) {
                    return RadioListTile<int>(
                      key: ValueKey(task[index]),  // 각 항목에 고유한 key를 설정
                      title: Text(task[index]),
                      value: index, // 각 Radio의 고유 값
                      groupValue: selectedValue, // 선택된 값과 비교할 그룹 값
                      onChanged: (int? value) {
                        setState(() {
                          selectedValue = value!; // 선택된 값을 업데이트
                        });
                      },
                    );
                  },
                ),
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
              SizedBox(
                height: 15,
              )
            ],
          ),

        )
    );
  }
}

//새로운 페이지

