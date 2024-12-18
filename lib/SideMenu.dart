// SideMenu.dart
import 'package:appproject/FeedBackPage.dart';
import 'package:appproject/Filemanagement.dart';
import 'package:flutter/material.dart';
import 'package:appproject/TodayPage.dart';
import 'package:appproject/WeekPage.dart';
import 'package:appproject/DatePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appproject/LoginPage.dart';
import 'package:appproject/MemorizeSetting.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // 테두리 둥글기 제거
      ),
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/sidebar_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(), // DrawerHeader 투명 배경
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // 하단 정렬
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.email, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        user?.email ?? '로그인 정보 없음',
                          style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25, fontWeight: FontWeight.bold,),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // 이메일 아래 약간의 여백
                ],
              ),
            ),
            ListTile(
              title: const Text('오늘의 할 일 리스트' , style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25, fontWeight: FontWeight.bold,)),
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  // TodayPage를 호출할 때 selectedDay 인자를 전달
                  MaterialPageRoute(builder: (context) => TodayPage(selectedDay: DateTime.now())),
                );
              },
            ),
            ListTile(
              title: const Text('날짜별 할 일', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25, fontWeight: FontWeight.bold,)),
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DatePage()),
                );
              },
            ),
            ListTile(
              title: const Text('habit tracker', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25, fontWeight: FontWeight.bold,)),
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WeekPage()),
                );
              },
            ),
            ListTile(
              title: const Text('달성률 확인', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25, fontWeight: FontWeight.bold,)),
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const FeedBackPage()),
                );
              },
            ),
            ListTile(
              title: const Text('공부 자료 관리', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25, fontWeight: FontWeight.bold,)),
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const FileManagement()),
                );
              },
            ),
            ListTile(
              title: const Text('암기 DB 설정', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25, fontWeight: FontWeight.bold,)),
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MemorizeSetting()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('로그아웃', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25, fontWeight: FontWeight.bold,)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
