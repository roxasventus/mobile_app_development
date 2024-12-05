// RegisterPage.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appproject/TodayPage.dart';
import 'package:appproject/SuccessRegister.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';


class RegisterPage extends StatelessWidget{
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('회원가입 ',style: TextStyle(fontFamily: 'TmonMonsori.ttf.ttf', fontSize: 30, color: Colors.white )),
            Text('Register', style: TextStyle(fontFamily: 'TmonMonsori.ttf.ttf',fontSize: 15, color: Colors.white),),
          ],
        ),
        backgroundColor: Colors.green.shade300,
      ),
      backgroundColor: Colors.lightGreen.shade300,
      body: const RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget{
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm>{
  bool saving = false;
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String userName = '';
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


              SizedBox(height: 20,),

              Container(
                width: 200,
                height: 100,
                child: Image.asset('assets/images/Pencil.png', fit: BoxFit.contain),
              ),
              Text('어플 이름',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'TmonMonsori.ttf.ttf', fontSize: 40, color: Colors.white),),
              Text('여기에 어플 설명을 한 줄',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'TmonMonsori.ttf.ttf', fontSize: 20, color: Colors.white),),

              SizedBox(height: 20,),


              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    fontFamily: 'mitMi.ttf.ttf', // 라벨에 적용할 글꼴
                    fontSize: 25, // 라벨 텍스트 색상
                  ),
                ),
                onChanged: (value){
                  email = value;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    fontFamily: 'mitMi.ttf.ttf', // 라벨에 적용할 글꼴
                    fontSize: 25, // 라벨 텍스트 색상
                  ),
                ),
                style: TextStyle(
                  fontFamily: 'mitMi.ttf.ttf', // 입력 텍스트에 적용할 글꼴
                  fontSize: 25,
                  color: Colors.black, // 입력 텍스트 색상
                ),
                onChanged: (value){
                  password = value;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'User Name',
                  labelStyle: TextStyle(
                    fontFamily: 'mitMi.ttf.ttf', // 라벨에 적용할 글꼴
                    fontSize: 25, // 라벨 텍스트 색상
                  ),
                ),
                style: TextStyle(
                  fontFamily: 'mitMi.ttf.ttf', // 입력 텍스트에 적용할 글꼴
                  fontSize: 25,
                  color: Colors.black, // 입력 텍스트 색상
                ),
                onChanged: (value){
                  userName = value;
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(onPressed: () async {
                try {
                  setState(() {
                    saving = true;
                  });
                  final newUser = await _authentication.createUserWithEmailAndPassword(email: email, password: password);
                  await FirebaseFirestore.instance.collection('user').doc(newUser.user!.uid).set({
                    'userName': userName,
                    'email': email,
                  });
                  if (newUser.user != null){
                    _formKey.currentState!.reset();
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> const TodayPage()));
                  }
                  setState(() {
                    saving = false;
                  });
                }
                catch(e){
                  print(e);
                }
              }, child: Text('Enter',
                style: TextStyle(fontFamily: 'TmonMonsori.ttf.ttf', fontSize: 20, color: Colors.black),)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('If you already register,',
                    style: TextStyle(fontFamily: 'mitMi.ttf.ttf', fontSize: 20, color: Colors.black),),
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: Text('log in with your email.',
                    style: TextStyle(fontFamily: 'mitMi.ttf.ttf', fontSize: 20, color: Colors.deepPurple),)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
