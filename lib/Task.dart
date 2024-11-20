// lib/task.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  bool isCompleted;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.date,
    this.isCompleted = false,
  }) : id = id ?? Uuid().v4();

  // Firestore에서 데이터를 가져올 때 사용
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  // Firestore에 데이터를 저장할 때 사용
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'isCompleted': isCompleted,
    };
  }
}
