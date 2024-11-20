import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_project/TodayPage.dart';
import 'package:pigeon_generated/pigeon_api.dart'; // Pigeon API가 자동 생성된 파일

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: const RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

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
            const SizedBox(height: 20),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              onChanged: (value) {
                password = value;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final newUser = await _authentication.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  if (newUser.user != null) {
                    _formKey.currentState!.reset();

                    // 추가 사용자 정보 가져오기
                    await fetchAdditionalUserDetails(newUser.user!);

                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TodayPage(),
                      ),
                    );
                  }
                } catch (e) {
                  print(e);
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchAdditionalUserDetails(User user) async {
    try {
      final result = await PigeonApi.getUserDetails(user.uid); // Pigeon 호출
      if (result is List<Object?> && result.isNotEmpty) {
        try {
          // 반환값을 변환하여 PigeonUserDetails 객체 생성
          final userDetails = PigeonUserDetails(
            name: result[0] as String,
            age: result[1] as int,
          );
          print('User details fetched: $userDetails');
        } catch (e) {
          print('Error converting result to PigeonUserDetails: $e');
        }
      } else {
        print('Unexpected result type: ${result.runtimeType}');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }
}
