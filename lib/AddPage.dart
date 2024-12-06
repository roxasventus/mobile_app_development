import 'package:flutter/material.dart';
import 'SideMenu.dart';
import 'AddPageWork.dart';
import 'AddPageIncomplete.dart';
import 'AddPagePast.dart';

// 탭별 내용 분리하여 사용

class AddPage extends StatelessWidget {
  const AddPage({super.key, required this.selectedDay});
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    String formattedDate = "${selectedDay.month}월 ${selectedDay.day}일 작업 추가";

    return DefaultTabController(
      length: 3, // 3개의 탭
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(formattedDate),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: '할 일'),
              Tab(text: '미완성'),
              Tab(text: '과거기록'),
            ],
          ),
        ),
        drawer: const SideMenu(),
        body: TabBarView(
          children: [
            AddPageWork(selectedDay: selectedDay),
            AddPageIncomplete(),
            AddPagePast(selectedDay: selectedDay),
          ],
        ),
      ),
    );
  }
}
