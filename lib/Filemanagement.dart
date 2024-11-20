// lib/FileManagement.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'SideMenu.dart';
import 'TaskProvider.dart';

class FileManagement extends StatefulWidget {
  const FileManagement({super.key});

  @override
  State<FileManagement> createState() => _FileManagementState();
}

class _FileManagementState extends State<FileManagement> {
  final _searchController = TextEditingController();
  List<File> _files = []; // Local files
  List<Map<String, dynamic>> _fileMetadata = []; // Firestore metadata

  @override
  void initState() {
    super.initState();
    _initializeFiles();
    _fetchFileMetadata();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Initialize local files directory
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

  // Fetch file metadata from Firestore
  Future<void> _fetchFileMetadata() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('files').get();
      setState(() {
        _fileMetadata = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Error fetching file metadata: $e');
    }
  }

  // Pick and copy a file to local storage and save metadata to Firestore
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

      // Save file metadata to Firestore
      await FirebaseFirestore.instance.collection('files').add({
        'name': copiedFile.uri.pathSegments.last,
        'path': copiedFile.path,
        'uploaded_at': Timestamp.now(),
      });

      setState(() {
        _files.add(copiedFile);
        _fileMetadata.add({
          'name': copiedFile.uri.pathSegments.last,
          'path': copiedFile.path,
          'uploaded_at': Timestamp.now(),
        });
      });
    }
  }

  // Open a file
  void _openFile(File file) {
    OpenFile.open(file.path);
  }

  // Delete a file and its metadata
  void _deleteFile(File file) async {
    if (await file.exists()) {
      await file.delete();

      // Delete file metadata from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('files')
          .where('path', isEqualTo: file.path)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _files.remove(file);
        _fileMetadata.removeWhere((meta) => meta['path'] == file.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자료 관리'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            child: Text('총 파일: ${_files.length}'),
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
                    // Implement search functionality
                    setState(() {
                      if (value.isEmpty) {
                        _initializeFiles();
                        _fetchFileMetadata();
                      } else {
                        _files = _files.where((file) => file.uri.pathSegments.last.contains(value)).toList();
                      }
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
