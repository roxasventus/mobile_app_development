import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';
import 'SideMenu.dart';
import 'BackgroundContainer.dart'; // BackgroundContainer import 추가

class FileManagement extends StatefulWidget {
  const FileManagement({Key? key}) : super(key: key);

  @override
  State<FileManagement> createState() => _FileManagementState();
}

class _FileManagementState extends State<FileManagement> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _fileMetadata = [];
  List<Map<String, dynamic>> _filteredMetadata = [];

  Set<String> _allTags = {'전체', '임시태그'};
  String _selectedTag = '전체';

  @override
  void initState() {
    super.initState();
    _fetchFileMetadata();
  }

  Future<void> _fetchFileMetadata() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('fileLinks')
          .where('userId', isEqualTo: user.uid)
          .get();

      final data = snapshot.docs.map((doc) {
        final d = doc.data();
        final rawTag = d['tags'];
        String tag;
        if (rawTag is String && rawTag.isNotEmpty) {
          tag = rawTag;
        } else {
          tag = '임시태그';
        }

        return {
          'id': doc.id,
          'name': d['name'],
          'path': d['path'],
          'uploadedAt': d['uploadedAt'],
          'userId': d['userId'],
          'tags': tag,
        };
      }).toList();

      setState(() {
        _fileMetadata = data;
        _refreshTags();
        _applyFilter();
      });
    } catch (e) {
      print('Error fetching file metadata: $e');
    }
  }

  void _refreshTags() {
    final tags = _fileMetadata.map((f) => f['tags'] as String).toSet();
    tags.add('임시태그');
    tags.add('전체');
    _allTags = tags;
  }

  Future<String> _showTagDialog() async {
    TextEditingController tagController = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('tag 입력'),
        content: TextField(
          controller: tagController,
          decoration: const InputDecoration(
              hintText: 'tag 입력 (미지정 시 임시태그)'
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, '');
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final input = tagController.text.trim();
              Navigator.pop(context, input);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
    return tag ?? '';
  }

  Future<void> _selectAndSaveFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final selectedFilePath = result.files.single.path!;
      final fileName = result.files.single.name;
      final user = _auth.currentUser;

      if (user == null) return;

      final tag = await _showTagDialog();
      final finalTag = tag.isEmpty ? '임시태그' : tag;

      try {
        final fileMetadata = {
          'name': fileName,
          'path': selectedFilePath,
          'uploadedAt': Timestamp.now(),
          'userId': user.uid,
          'tags': finalTag,
        };

        final docRef = await _firestore.collection('fileLinks').add(fileMetadata);

        setState(() {
          _fileMetadata.add({
            'id': docRef.id,
            ...fileMetadata,
          });
          _refreshTags();
          _applyFilter();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File link saved successfully!')),
        );
      } catch (e) {
        print('Error saving file link: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving file link.')),
        );
      }
    }
  }

  Future<void> _openFile(String path) async {
    try {
      final result = await OpenFile.open(path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening file.')),
        );
      }
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  Future<void> _deleteFile(String fileId) async {
    try {
      await _firestore.collection('fileLinks').doc(fileId).delete();

      setState(() {
        _fileMetadata.removeWhere((file) => file['id'] == fileId);
        _refreshTags();
        _selectedTag = '전체';
        _applyFilter();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File link deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting file link: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting file link.')),
      );
    }
  }

  void _applyFilter() {
    if (_selectedTag == '전체') {
      _filteredMetadata = List.from(_fileMetadata);
    } else {
      _filteredMetadata = _fileMetadata.where((file) => file['tags'] == _selectedTag).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text("자료 관리"),
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
      ),
      drawer: const SideMenu(),
      body: BackgroundContainer(
        imagePath: 'assets/images/background.png',
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('태그 필터: ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedTag,
                      items: _allTags.map((tag) {
                        return DropdownMenuItem<String>(
                          value: tag,
                          child: Text(tag),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedTag = value;
                            _applyFilter();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _filteredMetadata.isEmpty
                  ? const Center(child: Text('No files found.'))
                  : ListView.builder(
                itemCount: _filteredMetadata.length,
                itemBuilder: (context, index) {
                  final file = _filteredMetadata[index];
                  final tag = file['tags'] as String;
                  return ListTile(
                    title: Text(file['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Path: ${file['path']}'),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Chip(label: Text(tag)),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteFile(file['id']),
                    ),
                    onTap: () => _openFile(file['path']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectAndSaveFile,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
