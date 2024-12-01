import 'package:flutter/material.dart';
import 'SideMenu.dart'; // 사이드 메뉴를 가져옵니다.

class Filemanagement extends StatefulWidget {
  const Filemanagement({super.key});

  @override
  State<Filemanagement> createState() => _FilemanagementState();
}

class _FilemanagementState extends State<Filemanagement> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('자료 관리'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // 사이드 메뉴 열기
              },
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {}, // 로그아웃 동작 추가 가능
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const SideMenu(), // 사이드 메뉴 추가
      body: Column(
        children: [
          // 텍스트 리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 20, // 예시 데이터 개수
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '파일 ${index + 1}', // 리스트 항목 텍스트
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
          // 회색 하단바
          Container(
            height: 50,
            color: Colors.grey,
            alignment: Alignment.center,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {}, // 검색 버튼 동작 추가 가능
                icon: const Icon(Icons.search),
              ),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '검색',
                  ),
                  controller: _searchController,
                ),
              ),
              IconButton(
                onPressed: () {}, // 파일 추가 버튼 동작 추가 가능
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
