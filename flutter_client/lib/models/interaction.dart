/// Represents an interaction log from the LMS backend.
class Interaction {
  final int id;
  final int learnerId;
  final int itemId;
  final String kind;
  final double? score;

  Interaction({
    required this.id,
    required this.learnerId,
    required this.itemId,
    required this.kind,
    this.score,
  });

  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      id: json['id'] as int,
      learnerId: json['learner_id'] as int,
      itemId: json['item_id'] as int,
      kind: json['kind'] as String,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
    );
  }
}
