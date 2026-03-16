import '../models/tag.dart';
import '../models/todo.dart';

abstract class TodoRepository {
  // To-do CRUD
  Future<List<Todo>> getTodos(String userId);
  Future<void> saveTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);

  // Tag 관리
  Future<List<Tag>> getTags();
  Future<void> saveTag(Tag tag);
  Future<void> deleteTag(String id);

  // 임시 저장 (Draft)
  Future<void> saveDraft(Map<String, dynamic> draftData);
  Future<Map<String, dynamic>?> getDraft();
  Future<void> clearDraft();
}
