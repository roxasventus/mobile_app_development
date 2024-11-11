import 'package:flutter/material.dart';
import 'main.dart';

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
        title: Text('자료 관리'),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.menu),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          // 텍스트 리스트
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: 20, // 예시 데이터 개수
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '파일 ${index + 1}', // 리스트 항목 텍스트
                    style: TextStyle(fontSize: 16),
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
                onPressed: () {},
                icon: Icon(Icons.search),
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '검색',
                  ),
                  controller: _searchController,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}