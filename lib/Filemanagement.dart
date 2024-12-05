// Filemanagement.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';

class FileManagement extends StatefulWidget {
  const FileManagement({Key? key}) : super(key: key);

  @override
  State<FileManagement> createState() => _FileManagementState();
}

class _FileManagementState extends State<FileManagement> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _fileMetadata = [];

  @override
  void initState() {
    super.initState();
    _fetchFileMetadata();
  }

  // Fetch file metadata for the logged-in user
  Future<void> _fetchFileMetadata() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('fileLinks')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        _fileMetadata = snapshot.docs
            .map((doc) => {
          'id': doc.id,
          ...doc.data(),
        })
            .toList();
      });
    } catch (e) {
      print('Error fetching file metadata: $e');
    }
  }

  // Select a file and save its path in Firestore
  Future<void> _selectAndSaveFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final selectedFilePath = result.files.single.path!;
      final fileName = result.files.single.name;
      final user = _auth.currentUser;

      if (user == null) return;

      try {
        final fileMetadata = {
          'name': fileName,
          'path': selectedFilePath,
          'uploadedAt': Timestamp.now(),
          'userId': user.uid,
        };

        // Save metadata to Firestore
        final docRef = await _firestore.collection('fileLinks').add(fileMetadata);

        setState(() {
          _fileMetadata.add({
            'id': docRef.id,
            ...fileMetadata,
          });
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

  // Open a file using its path
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

  // Delete a file link
  Future<void> _deleteFile(String fileId) async {
    try {
      await _firestore.collection('fileLinks').doc(fileId).delete();

      setState(() {
        _fileMetadata.removeWhere((file) => file['id'] == fileId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자료 관리'),
        actions: [
          IconButton(
            onPressed: _selectAndSaveFile,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _fileMetadata.isEmpty
          ? const Center(child: Text('No files found.'))
          : ListView.builder(
        itemCount: _fileMetadata.length,
        itemBuilder: (context, index) {
          final file = _fileMetadata[index];
          return ListTile(
            title: Text(file['name']),
            subtitle: Text('Path: ${file['path']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteFile(file['id']),
            ),
            onTap: () => _openFile(file['path']),
          );
        },
      ),
    );
  }
}
