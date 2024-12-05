// lib/Task.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String userName;
  bool isCompleted;
  final DateTime? startTime; // 추가된 필드
  final DateTime? endTime;   // 추가된 필드

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.date,
    required this.userName,
    this.isCompleted = false,
    this.startTime, // 초기화
    this.endTime,   // 초기화
  }) : id = id ?? const Uuid().v4();

  // 팩토리 생성자 이름을 fromSnapshot으로 변경
  factory Task.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      userName: data['userName'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      startTime: data['startTime'] != null ? (data['startTime'] as Timestamp).toDate() : null, // 추가
      endTime: data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null,       // 추가
    );
  }

  // toMap 메서드 업데이트
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'userName': userName,
      'isCompleted': isCompleted,
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null, // 추가
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,       // 추가
    };
  }
}
