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
  final DateTime? startTime;
  final DateTime? endTime;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.date,
    required this.userName,
    this.isCompleted = false,
    this.startTime,
    this.endTime,
  }) : id = id ?? const Uuid().v4();

  factory Task.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id, // Firestore 문서의 ID 사용 -> 중요!
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      // Firestore에서 Timestamp는 UTC 시간. toLocal()로 로컬 변환
      date: (data['date'] as Timestamp).toDate().toLocal(),
      userName: data['userName'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate().toLocal()
          : null,
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate().toLocal()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toUtc(),
      'userName': userName,
      'isCompleted': isCompleted,
      'startTime': startTime?.toUtc(),
      'endTime': endTime?.toUtc(),
    };
  }
}
