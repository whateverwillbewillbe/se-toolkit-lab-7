/// Analytics models for scores, pass-rates, timeline, etc.

class ScoreBucket {
  final String bucket;
  final int count;

  ScoreBucket({required this.bucket, required this.count});

  factory ScoreBucket.fromJson(Map<String, dynamic> json) {
    return ScoreBucket(
      bucket: json['bucket'] as String,
      count: json['count'] as int,
    );
  }
}

class TaskPassRate {
  final String task;
  final double avgScore;
  final int attempts;

  TaskPassRate({
    required this.task,
    required this.avgScore,
    required this.attempts,
  });

  factory TaskPassRate.fromJson(Map<String, dynamic> json) {
    return TaskPassRate(
      task: json['task'] as String,
      avgScore: (json['avg_score'] as num).toDouble(),
      attempts: json['attempts'] as int,
    );
  }
}

class TimelineEntry {
  final String date;
  final int submissions;

  TimelineEntry({required this.date, required this.submissions});

  factory TimelineEntry.fromJson(Map<String, dynamic> json) {
    return TimelineEntry(
      date: json['date'] as String,
      submissions: json['submissions'] as int,
    );
  }
}

class GroupPerformance {
  final String group;
  final double avgScore;
  final int students;

  GroupPerformance({
    required this.group,
    required this.avgScore,
    required this.students,
  });

  factory GroupPerformance.fromJson(Map<String, dynamic> json) {
    return GroupPerformance(
      group: json['group'] as String,
      avgScore: (json['avg_score'] as num).toDouble(),
      students: json['students'] as int,
    );
  }
}

class CompletionRate {
  final String lab;
  final double completionRate;
  final int passed;
  final int total;

  CompletionRate({
    required this.lab,
    required this.completionRate,
    required this.passed,
    required this.total,
  });

  factory CompletionRate.fromJson(Map<String, dynamic> json) {
    return CompletionRate(
      lab: json['lab'] as String,
      completionRate: (json['completion_rate'] as num).toDouble(),
      passed: json['passed'] as int,
      total: json['total'] as int,
    );
  }
}

class TopLearner {
  final int learnerId;
  final double avgScore;
  final int attempts;

  TopLearner({
    required this.learnerId,
    required this.avgScore,
    required this.attempts,
  });

  factory TopLearner.fromJson(Map<String, dynamic> json) {
    return TopLearner(
      learnerId: json['learner_id'] as int,
      avgScore: (json['avg_score'] as num).toDouble(),
      attempts: json['attempts'] as int,
    );
  }
}
