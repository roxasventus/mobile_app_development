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
        title: Text('Login'),
      ),
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const TodayPage()),
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
                child: const Text('Enter'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('If you did not register,'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: const Text('Register your email'),
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
