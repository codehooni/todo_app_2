import 'package:cloud_firestore/cloud_firestore.dart';

import 'todo_remote_datasource.dart';
import '../../domain/models/tag.dart';
import '../../domain/models/todo.dart';

class TodoRemoteDatasourceFirebase implements TodoRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createTodo(Todo todo) async =>
      await _firestore.collection('todos').doc(todo.id).set({
        ...todo.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<List<Todo>> readTodos(String userId) async {
    final snapshot = await _firestore
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      DateTime parseDate(dynamic v) =>
          v is Timestamp ? v.toDate() : DateTime.parse(v as String);
      return Todo(
        userId: data['userId'] as String,
        id: doc.id,
        title: data['title'] as String,
        imageUrl: data['imageUrl'] as String?,
        tagIds: List<String>.from(data['tagIds']),
        createdAt: parseDate(data['createdAt']),
        updatedAt: parseDate(data['updatedAt']),
        isCompleted: data['isCompleted'] as bool,
      );
    }).toList();
  }

  @override
  Future<void> updateTodo(Todo todo) async => await _firestore
      .collection('todos')
      .doc(todo.id)
      .update({...todo.toJson(), 'updatedAt': FieldValue.serverTimestamp()});

  @override
  Future<void> deleteTodo(String id) async =>
      await _firestore.collection('todos').doc(id).delete();

  @override
  Future<void> createTag(Tag tag) async =>
      await _firestore.collection('tags').doc(tag.id).set(tag.toJson());

  @override
  Future<List<Tag>> readTags() async {
    final snapshot = await _firestore.collection('tags').get();

    return snapshot.docs.map((doc) => Tag.fromJson(doc.data())).toList();
  }

  @override
  Future<void> deleteTag(String id) async =>
      await _firestore.collection('tags').doc(id).delete();
}
