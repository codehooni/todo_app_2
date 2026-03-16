import 'package:hive_ce/hive_ce.dart';
import 'package:todo_app_2/features/todo/data/datasource/todo_local_datasource.dart';

class TodoLocalDataSourceHive implements TodoLocalDatasource {
  Box get _draftBox => Hive.box('draft');

  @override
  Future<Map<String, dynamic>?> getDraft() async {
    return _draftBox.get('current_draft')?.cast<String, dynamic>();
  }

  @override
  Future<void> saveDraft(Map<String, dynamic> draftData) async {
    await _draftBox.put('current_draft', draftData);
  }

  @override
  Future<void> clearDraft() async => await _draftBox.delete('current_draft');
}
