// task.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'TaskManager.dart';  // Import TaskManager to use it for fetching current user name

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String userName; // User name to associate tasks with users
  bool isCompleted;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.date,
    required this.userName, // User name is now required
    this.isCompleted = false,
  }) : id = id ?? Uuid().v4();

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      userName: data['userName'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  // toMap method now uses TaskManager to get the current user's userName
  Future<Map<String, dynamic>> toMap() async {
    final taskManager = TaskManager();
    final currentUserName = await taskManager.currentUserName; // Fetch current user's name
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'userName': currentUserName, // Use current user's userName
      'isCompleted': isCompleted,
    };
  }
}