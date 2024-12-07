import 'package:flutter/material.dart';
import 'SideMenu.dart';
import 'AddPageWork.dart';
import 'AddPageIncomplete.dart';
import 'AddPagePast.dart';
import 'BackgroundContainer.dart'; // BackgroundContainer 추가

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
          title: Text(formattedDate, style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 30)),
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
        ),
        drawer: const SideMenu(),
        body: BackgroundContainer(
          imagePath: 'assets/images/background.png', // 배경 이미지 경로
          child: Column(
            children: [
              const TabBar(
                labelStyle: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25),
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
      ),
    );
  }
}
