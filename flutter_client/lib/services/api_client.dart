import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/item.dart';
import '../models/learner.dart';
import '../models/interaction.dart';
import '../models/analytics.dart';

/// API client for the LMS backend.
/// Uses Bearer token authentication.
class LmsApiClient {
  final String baseUrl;
  final String apiKey;

  LmsApiClient({
    required this.baseUrl,
    required this.apiKey,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

  // ========== Items ==========

  /// Get all items (labs and tasks).
  Future<List<Item>> getItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/items/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Item.fromJson(item)).toList();
    } else {
      throw ApiException('Failed to load items: ${response.statusCode}');
    }
  }

  /// Get a specific item by ID.
  Future<Item> getItem(int itemId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/items/$itemId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Item.fromJson(json.decode(response.body));
    } else {
      throw ApiException('Failed to load item: ${response.statusCode}');
    }
  }

  // ========== Learners ==========

  /// Get all learners.
  Future<List<Learner>> getLearners() async {
    final response = await http.get(
      Uri.parse('$baseUrl/learners/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((learner) => Learner.fromJson(learner)).toList();
    } else {
      throw ApiException('Failed to load learners: ${response.statusCode}');
    }
  }

  // ========== Interactions ==========

  /// Get all interactions, optionally filtered by item.
  Future<List<Interaction>> getInteractions({int? itemId}) async {
    final uri = itemId != null
        ? Uri.parse('$baseUrl/interactions/?item_id=$itemId')
        : Uri.parse('$baseUrl/interactions/');

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((interaction) => Interaction.fromJson(interaction)).toList();
    } else {
      throw ApiException('Failed to load interactions: ${response.statusCode}');
    }
  }

  // ========== Analytics ==========

  /// Get score distribution for a lab.
  Future<List<ScoreBucket>> getScores(String lab) async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/scores?lab=$lab'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((bucket) => ScoreBucket.fromJson(bucket)).toList();
    } else {
      throw ApiException('Failed to load scores: ${response.statusCode}');
    }
  }

  /// Get pass rates for tasks in a lab.
  Future<List<TaskPassRate>> getPassRates(String lab) async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/pass-rates?lab=$lab'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((rate) => TaskPassRate.fromJson(rate)).toList();
    } else {
      throw ApiException('Failed to load pass rates: ${response.statusCode}');
    }
  }

  /// Get submission timeline for a lab.
  Future<List<TimelineEntry>> getTimeline(String lab) async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/timeline?lab=$lab'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((entry) => TimelineEntry.fromJson(entry)).toList();
    } else {
      throw ApiException('Failed to load timeline: ${response.statusCode}');
    }
  }

  /// Get group performance for a lab.
  Future<List<GroupPerformance>> getGroups(String lab) async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/groups?lab=$lab'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((group) => GroupPerformance.fromJson(group)).toList();
    } else {
      throw ApiException('Failed to load groups: ${response.statusCode}');
    }
  }

  /// Get completion rate for a lab.
  Future<CompletionRate> getCompletionRate(String lab) async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/completion-rate?lab=$lab'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return CompletionRate.fromJson(json.decode(response.body));
    } else {
      throw ApiException('Failed to load completion rate: ${response.statusCode}');
    }
  }

  /// Get top learners for a lab.
  Future<List<TopLearner>> getTopLearners(String lab, {int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/top-learners?lab=$lab&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((learner) => TopLearner.fromJson(learner)).toList();
    } else {
      throw ApiException('Failed to load top learners: ${response.statusCode}');
    }
  }

  /// Trigger ETL sync.
  Future<Map<String, dynamic>> sync() async {
    final response = await http.post(
      Uri.parse('$baseUrl/pipeline/sync'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException('Failed to sync: ${response.statusCode}');
    }
  }
}

/// Exception thrown when an API request fails.
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
