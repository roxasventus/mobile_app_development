// lib/TaskManager.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Task.dart';

class TaskManager {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance.collection('tasks');

  // 특정 날짜의 할 일 가져오기
  Future<List<Task>> getTasksByDate(DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    QuerySnapshot querySnapshot = await _tasksCollection
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();

    List<Task> tasks = querySnapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList();
    return tasks;
  }

  // 할 일 추가
  Future<void> addTask(Task task) async {
    await _tasksCollection.doc(task.id).set(task.toMap());
  }

  // 할 일 삭제
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  // 할 일 완료 상태 토글
  Future<void> toggleTaskCompletion(String taskId, bool currentStatus) async {
    await _tasksCollection.doc(taskId).update({'isCompleted': !currentStatus});
  }

  // 실시간 할 일 스트림 가져오기
  Stream<List<Task>> fetchTasksStream() {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59, 999);

    return _tasksCollection
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList());
  }

  // 현재 사용자 이름 가져오기 (인증이 설정되어 있는 경우)
  Future<String> get currentUserName async {
    // 현재 사용자 이름을 가져오는 로직 구현
    // 예시:
    // User? user = FirebaseAuth.instance.currentUser;
    // return user?.displayName ?? 'Unknown User';
    return 'User'; // 임시로 'User' 반환
  }

  // 할 일 순서 업데이트 (재정렬 기능을 구현하는 경우)
  Future<void> updateTaskOrder(String taskId, int order) async {
    await _tasksCollection.doc(taskId).update({'order': order});
  }

  // 일주일 전의 할 일 가져오기
  Future<List<Task>> getTasksOneWeekAgo(DateTime referenceDate) async {
    DateTime oneWeekAgo = DateTime(referenceDate.year, referenceDate.month, referenceDate.day)
        .subtract(const Duration(days: 7));

    DateTime startOfDay = DateTime(oneWeekAgo.year, oneWeekAgo.month, oneWeekAgo.day);
    DateTime endOfDay = DateTime(oneWeekAgo.year, oneWeekAgo.month, oneWeekAgo.day, 23, 59, 59, 999);

    QuerySnapshot querySnapshot = await _tasksCollection
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();

    List<Task> tasks = querySnapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList();
    return tasks;
  }
}
