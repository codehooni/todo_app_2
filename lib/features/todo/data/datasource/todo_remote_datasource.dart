import '../../domain/models/todo.dart';
import '../../domain/models/tag.dart';

abstract class TodoRemoteDatasource {
  Future<void> createTodo(Todo todo);
  Future<List<Todo>> readTodos(String userId);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);

  Future<void> createTag(Tag tag);
  Future<List<Tag>> readTags();
  Future<void> deleteTag(String id);
}
