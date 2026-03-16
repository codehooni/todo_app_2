import 'package:todo_app_2/features/todo/data/datasource/todo_local_datasource.dart';
import 'package:todo_app_2/features/todo/data/datasource/todo_remote_datasource_firebase.dart';

import '../datasource/todo_local_datasource_hive.dart';
import '../datasource/todo_remote_datasource.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../domain/models/todo.dart';
import '../../domain/models/tag.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDatasource _todoLocalDataSource;
  final TodoRemoteDatasource _todoRemoteDatasource;

  TodoRepositoryImpl([
    TodoLocalDatasource? todoLocalDataSource,
    TodoRemoteDatasource? todoRemoteDatasource,
  ]) : _todoLocalDataSource = todoLocalDataSource ?? TodoLocalDataSourceHive(),
       _todoRemoteDatasource =
           todoRemoteDatasource ?? TodoRemoteDatasourceFirebase();

  /// Remote - 'To-do' 받아오기
  // To-do 로직
  @override
  Future<List<Todo>> getTodos(String userId) async =>
      _todoRemoteDatasource.readTodos(userId);

  @override
  Future<void> saveTodo(Todo todo) async =>
      _todoRemoteDatasource.createTodo(todo);

  @override
  Future<void> updateTodo(Todo todo) async =>
      _todoRemoteDatasource.updateTodo(todo);

  @override
  Future<void> deleteTodo(String id) async =>
      _todoRemoteDatasource.deleteTodo(id);

  // Tag 로직
  @override
  Future<List<Tag>> getTags() async => _todoRemoteDatasource.readTags();

  @override
  Future<void> saveTag(Tag tag) async => _todoRemoteDatasource.createTag(tag);

  @override
  Future<void> deleteTag(String id) async =>
      _todoRemoteDatasource.deleteTag(id);

  /// Remote - 'Draft' 관리
  // Draft 로직: 단일 키('current_draft')로 관리하여 하나만 유지
  @override
  Future<void> saveDraft(Map<String, dynamic> draftData) async {
    await _todoLocalDataSource.saveDraft(draftData);
  }

  @override
  Future<Map<String, dynamic>?> getDraft() async =>
      _todoLocalDataSource.getDraft();

  @override
  Future<void> clearDraft() async => _todoLocalDataSource.clearDraft();
}
