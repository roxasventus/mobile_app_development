// SideMenu.dart
import 'package:appproject/FeedBackPage.dart';
import 'package:appproject/Filemanagement.dart';
import 'package:flutter/material.dart';
import 'package:appproject/TodayPage.dart';
import 'package:appproject/WeekPage.dart';
import 'package:appproject/DatePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appproject/LoginPage.dart'; // LoginPage 가져오기

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '사이드 메뉴',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('오늘의 할 일 리스트'),
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TodayPage()),
              );
            },
          ),
          ListTile(
            title: const Text('날짜별 할 일'),
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DatePage()),
              );
            },
          ),
          ListTile(
            title: const Text('habit tracker'),
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WeekPage()),
              );
            },
          ),
          ListTile(
            title: const Text('피드백'),
            onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FeedBackPage()),
              );
            },
          ),
          ListTile(
            title: const Text('공부 자료 관리'),
            onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FileManagement()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()), // 로그인 페이지로 이동
                    (route) => false, // 네비게이션 스택 초기화
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(
              user?.email ?? '로그인 정보 없음',
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
