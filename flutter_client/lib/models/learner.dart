/// Represents a learner (student) from the LMS backend.
class Learner {
  final int id;
  final String externalId;
  final String studentGroup;

  Learner({
    required this.id,
    required this.externalId,
    required this.studentGroup,
  });

  factory Learner.fromJson(Map<String, dynamic> json) {
    return Learner(
      id: json['id'] as int,
      externalId: json['external_id'] as String,
      studentGroup: json['student_group'] as String,
    );
  }
}
