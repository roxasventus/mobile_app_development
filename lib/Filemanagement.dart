import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:app_project/SideMenu.dart';

class FileManagement extends StatefulWidget {
  const FileManagement({super.key});

  @override
  State<FileManagement> createState() => _FileManagementState();
}

class _FileManagementState extends State<FileManagement> {
  final _searchController = TextEditingController();
  List<File> _files = []; // 복사된 파일 목록

  @override
  void initState() {
    super.initState();
    _initializeFiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 파일 초기화
  Future<void> _initializeFiles() async {
    final appDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory('${appDir.path}/files');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    setState(() {
      _files = targetDir.listSync().whereType<File>().toList();
    });
  }

  // 파일 선택 및 복사
  Future<void> _pickAndCopyFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final selectedFile = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${appDir.path}/files');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final targetPath = '${targetDir.path}/${selectedFile.uri.pathSegments.last}';
      final copiedFile = await selectedFile.copy(targetPath);

      setState(() {
        _files.add(copiedFile);
      });
    }
  }

  // 파일 열기
  void _openFile(File file) {
    OpenFile.open(file.path);
  }

  // 파일 삭제
  void _deleteFile(File file) async {
    if (await file.exists()) {
      await file.delete();
      setState(() {
        _files.remove(file);
      });
    }
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
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const SideMenu(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                return ListTile(
                  title: Text(file.uri.pathSegments.last),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.open_in_new, color: Colors.blue,),
                        onPressed: () => _openFile(file),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => _deleteFile(file),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
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
                onPressed: _pickAndCopyFile,
                icon: const Icon(Icons.add),
              ),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '검색',
                  ),
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _files = _files
                          .where((file) =>
                          file.uri.pathSegments.last.contains(value))
                          .toList();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
