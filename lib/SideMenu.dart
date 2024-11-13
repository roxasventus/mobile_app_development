// SideMenu.dart
import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(),
            child: Row(
              children: [
                const Text('사이드 메뉴'),
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
            title: const Text('날짜별 할 일'),
            onTap: () {
              Navigator.pushNamed(context, '/Today');
            },
          ),
          ListTile(
            title: const Text('기간별 할 일'),
            onTap: () {
              Navigator.pushNamed(context, '/Week');
            },
          ),
          ListTile(
            title: const Text('피드백'),
            onTap: () {
              Navigator.pushNamed(context, '/FeedBack');
            },
          ),
          ListTile(
            title: const Text('공부 자료 관리'),
            onTap: () {
              Navigator.pushNamed(context, '/File');
            },
          ),
        ],
      ),
    );
  }
}
