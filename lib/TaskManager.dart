// TaskManager.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Task.dart';

class TaskManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _tasksCollection =
  FirebaseFirestore.instance.collection('tasks');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's name
  Future<String> get currentUserName async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final userDoc = await _firestore.collection('user').doc(user.uid).get();
    return userDoc.data()?['userName'] ?? '';
  }

  // Fetch all tasks for the logged-in user (real-time listener)
  Stream<List<Task>> fetchTasksStream() async* {
    final userName = await currentUserName;
    yield* _tasksCollection
        .where('userName', isEqualTo: userName)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Fetch tasks for a specific date
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final userName = await currentUserName;
    try {
      final snapshot = await _tasksCollection
          .where('userName', isEqualTo: userName)
          .where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
              DateTime(date.year, date.month, date.day, 0, 0, 0))) // start of day
          .where('date',
          isLessThan: Timestamp.fromDate(
              DateTime(date.year, date.month, date.day, 23, 59, 59))) // end of day
          .get();

      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching tasks by date: $e');
      return [];
    }
  }

  // Fetch tasks created one week ago (from 7 days ago until the given date)
  Future<List<Task>> getTasksOneWeekAgo(DateTime date) async {
    final userName = await currentUserName;
    try {
      // 7일 전 날짜 계산
      final oneWeekAgo = date.subtract(const Duration(days: 7));

      // 7일 전부터 그날의 끝까지 필터링
      final startOfDay = DateTime(oneWeekAgo.year, oneWeekAgo.month, oneWeekAgo.day, 0, 0, 0);
      final endOfDay = DateTime(oneWeekAgo.year, oneWeekAgo.month, oneWeekAgo.day, 23, 59, 59);

      // Firestore에서 1주일 전의 특정 날짜에 해당하는 테스크들만 가져옴
      final snapshot = await _tasksCollection
          .where('userName', isEqualTo: userName)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching tasks from one week ago: $e');
      return [];
    }
  }



  // Add a new task
  Future<void> addTask(Task task) async {
    try {
      final taskData = await task.toMap();
      await _tasksCollection.add(taskData);
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String id, bool currentStatus) async {
    try {
      await _tasksCollection.doc(id).update({'isCompleted': !currentStatus});
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }

  // Update task order in Firestore
  Future<void> updateTaskOrder(String taskId, int newOrder) async {
    try {
      await _tasksCollection.doc(taskId).update({'order': newOrder});
    } catch (e) {
      print('Error updating task order: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    try {
      await _tasksCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  // Add a task to the taskList collection
  Future<void> addToTaskList(String title, String userName) async {
    try {
      await _firestore.collection('taskList').add({
        'title': title,
        'userName': userName,
      });
      print('Task added to taskList collection successfully!');
    } catch (e) {
      print('Error adding task to taskList: $e');
    }
  }

  // Fetch tasks from the taskList collection for the logged-in user
  Stream<List<Task>> fetchTaskListStream() async* {
    final userName = await currentUserName;  // Get the current user's username
    yield* _firestore
        .collection('taskList')
        .where('userName', isEqualTo: userName)  // Filter tasks by userName
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return Task(
        title: doc['title'],
        userName: doc['userName'],
        date: DateTime.now(),
        isCompleted: false,
      );
    }).toList())
        .asBroadcastStream();  // Broadcast stream for multiple listeners
  }

  // Fetch only incomplete tasks for the logged-in user
  Stream<List<Task>> fetchIncompleteTasksStream() async* {
    final userName = await currentUserName;

    yield* _tasksCollection
        .where('userName', isEqualTo: userName)
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Fetch tasks created one week ago (from 7 days ago until today) as a stream
  Stream<List<Task>> fetchPastTasksStream() async* {
    final userName = await currentUserName;
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

    yield* _tasksCollection
        .where('userName', isEqualTo: userName)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }
}