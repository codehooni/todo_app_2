abstract class TodoLocalDatasource {
  Future<void> saveDraft(Map<String, dynamic> draftData);
  Future<Map<String, dynamic>?> getDraft();
  Future<void> clearDraft();
}
