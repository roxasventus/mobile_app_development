// MemorizeView.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum MemorizeLanguage { english, japanese }

class MemorizeView extends StatefulWidget {
  const MemorizeView({Key? key}) : super(key: key);

  @override
  State<MemorizeView> createState() => _MemorizeViewState();
}

class _MemorizeViewState extends State<MemorizeView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MemorizeLanguage? _userLanguage;
  List<String> _linearList = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  // 캐싱을 위한 Map
  final Map<String, List<String>> _definitionCache = {};

  // 영어 단어 리스트 (필요 시 확장 가능)
  final List<String> _advancedEnglishWords = [
    'aberration',
    'capitulate',
    'deleterious',
    'enervate',
    'fortuitous',
    'gregarious',
    'hapless',
    'iconoclast',
    'juxtaposition',
    'laconic',
    'magnanimous',
    'nefarious',
    'obfuscate',
    'perfunctory',
    'quixotic',
    'recalcitrant',
    'sagacious',
    'taciturn',
    'ubiquitous',
    'vociferous'
  ];

  // 일본어 단어 리스트 (필요 시 확장 가능)
  final List<String> _advancedJapaneseWords = [
    '猫',     // Neko - Cat
    '食べる', // Taberu - To eat
    '学校',   // Gakkou - School
    '日本',   // Nihon - Japan
    '友達',   // Tomodachi - Friend
    '車',     // Kuruma - Car
    '本',     // Hon - Book
    '映画',   // Eiga - Movie
    '音楽',   // Ongaku - Music
    '先生',   // Sensei - Teacher
    '水',     // Mizu - Water
    '火',     // Hi - Fire
    '風',     // Kaze - Wind
    '土',     // Tsuchi - Earth/Soil
    '空',     // Sora - Sky
    '海',     // Umi - Sea
    '山',     // Yama - Mountain
    '川',     // Kawa - River
    '花',     // Hana - Flower
    '犬'      // Inu - Dog
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserLanguageAndData();
  }

  Future<void> _fetchUserLanguageAndData() async {
    final user = _auth.currentUser;
    if (user == null) {
      // 사용자가 로그인하지 않은 경우 처리
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Firestore에서 사용자 언어 설정 가져오기
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['memorizeLanguage'] != null) {
        final langStr = doc.data()?['memorizeLanguage'] as String;
        _userLanguage = (langStr == 'japanese') ? MemorizeLanguage.japanese : MemorizeLanguage.english;
      } else {
        _userLanguage = MemorizeLanguage.english; // 기본값 설정
      }

      // 언어에 따라 단어 리스트 선택
      List<String> selectedWords = (_userLanguage == MemorizeLanguage.english)
          ? _advancedEnglishWords
          : _advancedJapaneseWords;

      // 병렬로 단어 정의 가져오기
      List<Future<List<String>>> definitionFutures = selectedWords.map((word) {
        return (_userLanguage == MemorizeLanguage.english)
            ? _fetchEnglishDefinitions(word)
            : _fetchJapaneseDefinitions(word);
      }).toList();

      List<List<String>> allDefinitions = await Future.wait(definitionFutures);

      // 단어와 정의를 번갈아가며 추가
      List<String> tempList = [];
      for (int i = 0; i < selectedWords.length; i++) {
        tempList.add(selectedWords[i]); // 단어 추가
        tempList.add(allDefinitions[i].isNotEmpty ? allDefinitions[i][0] : 'No definition'); // 첫 번째 정의 추가
      }

      setState(() {
        _linearList = tempList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user language or data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<String>> _fetchEnglishDefinitions(String word) async {
    if (_definitionCache.containsKey(word)) {
      return _definitionCache[word]!;
    }

    final String baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';
    final url = Uri.parse('$baseUrl/$word');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<String> definitions = [];
        if (data.isNotEmpty) {
          final entry = data[0];
          final meanings = entry['meanings'] as List<dynamic>;
          for (var meaning in meanings) {
            final defs = meaning['definitions'] as List<dynamic>;
            for (var def in defs) {
              definitions.add(def['definition'] as String);
            }
          }
        }
        _definitionCache[word] = definitions;
        return definitions;
      } else {
        return ['No definition found'];
      }
    } catch (e) {
      print('Error fetching definition for $word: $e');
      return ['Error fetching definition'];
    }
  }

  Future<List<String>> _fetchJapaneseDefinitions(String word) async {
    if (_definitionCache.containsKey(word)) {
      return _definitionCache[word]!;
    }

    final String baseUrl = 'https://jisho.org/api/v1/search/words';
    final url = Uri.parse('$baseUrl?keyword=$word');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> definitions = [];
        if (data['data'] != null && data['data'].isNotEmpty) {
          final firstEntry = data['data'][0];
          final senses = firstEntry['senses'] as List<dynamic>;
          if (senses.isNotEmpty) {
            final englishDefs = senses[0]['english_definitions'] as List<dynamic>;
            if (englishDefs.isNotEmpty) {
              definitions.add(englishDefs[0].toString());
            }
          }
        }
        _definitionCache[word] = definitions;
        return definitions;
      } else {
        return ['No definition found'];
      }
    } catch (e) {
      print('Error fetching definition for $word: $e');
      return ['Error fetching definition'];
    }
  }

  void _nextItem() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _linearList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_linearList.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final displayText = _linearList[_currentIndex];

    return GestureDetector(
      onTap: _nextItem,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Text(
            displayText,
            style: const TextStyle(fontSize: 24, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
