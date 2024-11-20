import 'package:app_project/TodayPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'LoginPage.dart';
import 'RegisterPage.dart';
import 'SuccessRegister.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      // 계속 상태를 구독? 하도록 한다
      home: StreamBuilder( // 계속 상태를 들을수 있도록 하는 통로 역할
          stream: FirebaseAuth.instance.authStateChanges(), // 인증 state가 바뀌는지 stream을 통해서 듣는다
          builder: (context, snapshot) { // 변화가 일어난 시점의 snapshot을 찍는다
            if (snapshot.hasData) {
              // snapshot이 data가 있다면 로그인 된거니까 ChatPage가 홈으로
              return const TodayPage();
            } else {
              // 아니라면 로그인 페이지가 홈으로
              return LoginPage();
            }
          }
      ),
    );
  }
}


