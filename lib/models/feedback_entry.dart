class FeedbackEntry {
  const FeedbackEntry({
    required this.id,
    required this.classId,
    required this.className,
    required this.pjName,
    required this.feedback,
    required this.date,
  });

  final String id;
  final String classId;
  final String className;
  final String pjName;
  final String feedback;
  final DateTime date;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'classId': classId,
      'className': className,
      'pjName': pjName,
      'feedback': feedback,
      'date': date.toIso8601String(),
    };
  }

  factory FeedbackEntry.fromMap(String id, Map<String, dynamic> map) {
    final String? dateStr = map['date'];
    final DateTime date = dateStr != null ? (DateTime.tryParse(dateStr) ?? DateTime.now()) : DateTime.now();
    return FeedbackEntry(
      id: id,
      classId: map['classId'] ?? '',
      className: map['className'] ?? '',
      pjName: map['pjName'] ?? '',
      feedback: map['feedback'] ?? '',
      date: date,
    );
  }
}
