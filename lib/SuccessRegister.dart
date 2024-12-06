// SuccessRegister.dart
import 'package:flutter/material.dart';

class SuccessRegister extends StatelessWidget{
  const SuccessRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Success Register'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have successfully registered', style: TextStyle(
              fontSize: 20,
            ),),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(onPressed: (){
              Navigator.popUntil(context, (route) => route.isFirst);
            }, child: Text('Login'))
          ],
        ),
      ),
    );
  }
}
