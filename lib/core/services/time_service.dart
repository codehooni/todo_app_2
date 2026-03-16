class TimeService {
  static String formatFull(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일';
  }

  static String formatRelative(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return '방금';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dtDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    if (dtDate == yesterday) return '어제';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dateTime.month}월 ${dateTime.day}일';
  }
}
