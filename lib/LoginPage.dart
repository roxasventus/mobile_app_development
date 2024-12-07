// LoginPage.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'RegisterPage.dart';
import 'TodayPage.dart'; // 로그인 성공 후 이동할 페이지
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('로그인 ', style: TextStyle(fontFamily: 'TmonMonsori.ttf.ttf', fontSize: 30, color: Colors.white)),
            Text('Login', style: TextStyle(fontFamily: 'TmonMonsori.ttf.ttf', fontSize: 15, color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.green.shade300,
      ),
      backgroundColor: Colors.lightGreen.shade300,
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool saving = false;
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: saving,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              Container(
                width: 200,
                height: 150,
                child: Image.asset('assets/images/StackedBook.png', fit: BoxFit.contain),
              ),
              Text(
                '차근차근',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'TmonMonsori.ttf.ttf', fontSize: 40, color: Colors.white),
              ),
              Text(
                '복잡한 하루를 단순하게',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'TmonMonsori.ttf.ttf', fontSize: 20, color: Colors.white),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    fontFamily: 'mitMi.ttf.ttf', // 라벨에 적용할 글꼴
                    fontSize: 25, // 라벨 텍스트 크기
                  ),
                ),
                style: TextStyle(
                  fontFamily: 'mitMi.ttf.ttf', // 입력 텍스트에 적용할 글꼴
                  fontSize: 25,
                  color: Colors.black, // 입력 텍스트 색상
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    fontFamily: 'mitMi.ttf.ttf', // 라벨에 적용할 글꼴
                    fontSize: 25, // 라벨 텍스트 크기
                  ),
                ),
                style: TextStyle(
                  fontFamily: 'mitMi.ttf.ttf', // 입력 텍스트에 적용할 글꼴
                  fontSize: 16,
                  color: Colors.black, // 입력 텍스트 색상
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  try {
                    setState(() {
                      saving = true;
                    });
                    final userCredential = await _authentication.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    if (userCredential.user != null) {
                      _formKey.currentState!.reset();
                      // 여기서 TodayPage로 넘어갈 때 selectedDay 전달
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => TodayPage(selectedDay: DateTime.now())),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  } finally {
                    setState(() {
                      saving = false;
                    });
                  }
                },
                child: const Text(
                  'Enter',
                  style: TextStyle(fontFamily: 'TmonMonsori.ttf.ttf', fontSize: 20, color: Colors.black),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'If you did not register,',
                    style: TextStyle(fontFamily: 'mitMi.ttf.ttf', fontSize: 20, color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: const Text(
                      'Register your email',
                      style: TextStyle(fontFamily: 'mitMi.ttf.ttf', fontSize: 20, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
