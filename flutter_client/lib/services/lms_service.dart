import 'package:flutter/foundation.dart';

import '../models/item.dart';
import '../models/learner.dart';
import '../models/interaction.dart';
import '../models/analytics.dart';
import 'api_client.dart';

/// Service that manages app state and API calls.
class LmsService extends ChangeNotifier {
  final LmsApiClient _client;

  LmsService({
    required String apiUrl,
    required String apiKey,
  }) : _client = LmsApiClient(baseUrl: apiUrl, apiKey: apiKey);

  // State
  List<Item> _items = [];
  List<Learner> _learners = [];
  List<Interaction> _interactions = [];
  
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Item> get items => _items;
  List<Item> get labs => _items.where((item) => item.isLab).toList();
  List<Item> get tasks => _items.where((item) => item.isTask).toList();
  List<Learner> get learners => _learners;
  List<Interaction> get interactions => _interactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get item by ID.
  Item? getItemById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get tasks for a specific lab.
  List<Item> getTasksForLab(int labId) {
    return _items.where((item) => item.parentId == labId).toList();
  }

  /// Load all items from the API.
  Future<void> loadItems() async {
    await _executeWithLoading(
      () async => _items = await _client.getItems(),
      'Failed to load items',
    );
  }

  /// Load all learners.
  Future<void> loadLearners() async {
    await _executeWithLoading(
      () async => _learners = await _client.getLearners(),
      'Failed to load learners',
    );
  }

  /// Load interactions.
  Future<void> loadInteractions({int? itemId}) async {
    await _executeWithLoading(
      () async => _interactions = await _client.getInteractions(itemId: itemId),
      'Failed to load interactions',
    );
  }

  /// Get scores for a lab.
  Future<List<ScoreBucket>> getScores(String lab) async {
    return await _client.getScores(lab);
  }

  /// Get pass rates for a lab.
  Future<List<TaskPassRate>> getPassRates(String lab) async {
    return await _client.getPassRates(lab);
  }

  /// Get timeline for a lab.
  Future<List<TimelineEntry>> getTimeline(String lab) async {
    return await _client.getTimeline(lab);
  }

  /// Get group performance for a lab.
  Future<List<GroupPerformance>> getGroups(String lab) async {
    return await _client.getGroups(lab);
  }

  /// Get completion rate for a lab.
  Future<CompletionRate> getCompletionRate(String lab) async {
    return await _client.getCompletionRate(lab);
  }

  /// Get top learners for a lab.
  Future<List<TopLearner>> getTopLearners(String lab, {int limit = 10}) async {
    return await _client.getTopLearners(lab, limit: limit);
  }

  /// Trigger ETL sync.
  Future<Map<String, dynamic>> sync() async {
    return await _client.sync();
  }

  /// Execute an async operation with loading state and error handling.
  Future<void> _executeWithLoading(
    Future<void> Function() operation,
    String errorMessage,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await operation();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
