// MemorizeSetting.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'SideMenu.dart';
import 'BackgroundContainer.dart';
import 'MemorizeView.dart';

enum MemorizeLanguage { english, japanese }

class MemorizeSetting extends StatefulWidget {
  const MemorizeSetting({Key? key}) : super(key: key);

  @override
  State<MemorizeSetting> createState() => _MemorizeSettingState();
}

class _MemorizeSettingState extends State<MemorizeSetting> {
  MemorizeLanguage _selectedLanguage = MemorizeLanguage.english;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserLanguage();
  }

  Future<void> _loadUserLanguage() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['memorizeLanguage'] != null) {
        final langStr = doc.data()?['memorizeLanguage'] as String;
        MemorizeLanguage lang = (langStr == 'japanese') ? MemorizeLanguage.japanese : MemorizeLanguage.english;
        setState(() {
          _selectedLanguage = lang;
        });
      }
    } catch (e) {
      print('Error loading language: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLanguageToDB(MemorizeLanguage language) async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    final docRef = _firestore.collection('users').doc(user.uid);
    final languageString = (language == MemorizeLanguage.english) ? 'english' : 'japanese';

    try {
      await docRef.set({'memorizeLanguage': languageString}, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('언어 설정이 저장되었습니다!')),
      );
    } catch (e) {
      print('Error saving language: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('언어 설정 저장 중 오류가 발생했습니다.')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _onConfirm() async {
    await _saveLanguageToDB(_selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<MemorizeLanguage>> languageItems = [
      DropdownMenuItem(
        value: MemorizeLanguage.english,
        child: const Text('영어 단어', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25),),
      ),
      DropdownMenuItem(
        value: MemorizeLanguage.japanese,
        child: const Text('일본어 단어', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25),),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('암기 설정', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/topbar_background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      drawer: const SideMenu(),
      body: BackgroundContainer(
        imagePath: 'assets/images/background.png',
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '암기할 언어를 선택하세요:',
              style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButton<MemorizeLanguage>(
                value: _selectedLanguage,
                items: languageItems,
                isExpanded: true,
                underline: const SizedBox(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
              ),
              onPressed: _isSaving ? null : _onConfirm,
              child: _isSaving
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text('확인', style: TextStyle(fontFamily: '나눔손글씨_미니_손글씨.ttf', fontSize: 25, color: Colors.white),),
            ),
            const SizedBox(height: 20),
            // MemorizeView 컨테이너 크기 조정
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              child: const MemorizeView(),
            ),
          ],
        ),
      ),
    );
  }
}
