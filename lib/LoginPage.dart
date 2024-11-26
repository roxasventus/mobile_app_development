import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'RegisterPage.dart';
import 'package:app_project/TodayPage.dart'; // 로그인 성공 후 이동할 페이지

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: const LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String errorMessage = ''; // 오류 메시지를 위한 변수

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) {
                email = value;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              onChanged: (value) {
                password = value;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Firebase Authentication을 사용하여 로그인 시도
                  final currentUser = await _authentication.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  if (currentUser.user != null) {
                    _formKey.currentState!.reset();
                    // 로그인 성공 시 TodayPage로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TodayPage(),
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    errorMessage = 'Error: ${e.code} - ${e.message ?? 'Unknown error'}'; // 오류 코드와 메시지
                  });
                  print("FirebaseAuthException: ${e.code}");
                  print("Error message: ${e.message}");  // 'details' 필드는 제거
                }
              },
              child: const Text('Enter'),
            ),
            if (errorMessage.isNotEmpty) // 에러 메시지가 있으면 화면에 표시
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('If you did not register,'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text('Register your email'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
