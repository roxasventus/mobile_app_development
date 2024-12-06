import 'package:flutter/material.dart';
import 'SideMenu.dart';
import 'AddPageWork.dart';
import 'AddPageIncomplete.dart';
import 'AddPagePast.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key, required this.selectedDay});
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    String formattedDate = "${selectedDay.month}월 ${selectedDay.day}일 작업 추가";

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/topbar_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
          // 여기서 bottom: TabBar(...) 제거
        ),
        drawer: const SideMenu(),
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: '할 일'),
                Tab(text: '미완성'),
                Tab(text: '과거기록'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AddPageWork(selectedDay: selectedDay),
                  AddPageIncomplete(),
                  AddPagePast(selectedDay: selectedDay),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
