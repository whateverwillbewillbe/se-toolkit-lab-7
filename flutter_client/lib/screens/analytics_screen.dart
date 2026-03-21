import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/analytics.dart';
import '../services/lms_service.dart';

/// Screen displaying analytics for a lab.
class AnalyticsScreen extends StatefulWidget {
  final int? labId;
  final int? taskId;

  const AnalyticsScreen({
    super.key,
    this.labId,
    this.taskId,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedLab = 'lab-01';
  
  // Analytics data
  List<TaskPassRate>? _passRates;
  List<ScoreBucket>? _scores;
  List<TimelineEntry>? _timeline;
  List<GroupPerformance>? _groups;
  CompletionRate? _completionRate;
  List<TopLearner>? _topLearners;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = context.read<LmsService>();

      final results = await Future.wait([
        service.getPassRates(_selectedLab),
        service.getScores(_selectedLab),
        service.getTimeline(_selectedLab),
        service.getGroups(_selectedLab),
        service.getCompletionRate(_selectedLab),
        service.getTopLearners(_selectedLab),
      ]);

      setState(() {
        _passRates = results[0] as List<TaskPassRate>;
        _scores = results[1] as List<ScoreBucket>;
        _timeline = results[2] as List<TimelineEntry>;
        _groups = results[3] as List<GroupPerformance>;
        _completionRate = results[4] as CompletionRate;
        _topLearners = results[5] as List<TopLearner>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading analytics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadAnalytics,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lab selector
            _buildLabSelector(),
            
            const SizedBox(height: 24),

            // Completion Rate Card
            if (_completionRate != null) _buildCompletionRateCard(),

            const SizedBox(height: 16),

            // Score Distribution
            if (_scores != null) _buildScoreDistributionCard(),

            const SizedBox(height: 16),

            // Pass Rates
            if (_passRates != null && _passRates!.isNotEmpty)
              _buildPassRatesCard(),

            const SizedBox(height: 16),

            // Timeline
            if (_timeline != null && _timeline!.isNotEmpty)
              _buildTimelineCard(),

            const SizedBox(height: 16),

            // Group Performance
            if (_groups != null && _groups!.isNotEmpty)
              _buildGroupsCard(),

            const SizedBox(height: 16),

            // Top Learners
            if (_topLearners != null && _topLearners!.isNotEmpty)
              _buildTopLearnersCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Lab',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedLab,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: [
                'lab-01',
                'lab-02',
                'lab-03',
                'lab-04',
                'lab-05',
                'lab-06',
                'lab-07',
              ].map((lab) => DropdownMenuItem(value: lab, child: Text(lab))).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLab = value;
                  });
                  _loadAnalytics();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionRateCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Completion Rate',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  'Completion',
                  '${_completionRate!.completionRate.toStringAsFixed(1)}%',
                  Icons.percent,
                ),
                _buildStatColumn(
                  'Passed',
                  '${_completionRate!.passed}',
                  Icons.check_circle,
                  color: Colors.green,
                ),
                _buildStatColumn(
                  'Total',
                  '${_completionRate!.total}',
                  Icons.people,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (_completionRate!.completionRate / 100).toDouble(),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildScoreDistributionCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Score Distribution',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._scores!.map((bucket) => _buildScoreBar(bucket)),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(ScoreBucket bucket) {
    final maxCount = _scores!.map((e) => e.count).reduce((a, b) => a > b ? a : b);
    final widthPercent = maxCount > 0 ? (bucket.count / maxCount).toDouble() : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              bucket.bucket,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widthPercent,
                minHeight: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${bucket.count}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassRatesCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pass Rates by Task',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _passRates!.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final rate = _passRates![index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(rate.task),
                  subtitle: Text('${rate.attempts} attempts'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${rate.avgScore.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(rate.avgScore),
                            ),
                      ),
                      Text(
                        'avg score',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Submission Timeline',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _timeline!.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final entry = _timeline![index];
                  final maxSubmissions =
                      _timeline!.map((e) => e.submissions).reduce((a, b) => a > b ? a : b);
                  final heightPercent =
                      maxSubmissions > 0 ? (entry.submissions / maxSubmissions).toDouble() : 0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${entry.submissions}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: (100 * heightPercent).toDouble(),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 60,
                        child: Text(
                          entry.date.substring(5), // Show MM-DD
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.groups,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Group Performance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Group')),
                DataColumn(label: Text('Avg Score'), numeric: true),
                DataColumn(label: Text('Students'), numeric: true),
              ],
              rows: _groups!
                  .map((group) => DataRow(cells: [
                        DataCell(Text(group.group)),
                        DataCell(
                          Text(
                            group.avgScore.toStringAsFixed(1),
                            style: TextStyle(
                              color: _getScoreColor(group.avgScore),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(Text('${group.students}')),
                      ]))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopLearnersCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Top Learners',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _topLearners!.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final learner = _topLearners![index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRankColor(index),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text('Learner #${learner.learnerId}'),
                  subtitle: Text('${learner.attempts} attempts'),
                  trailing: Text(
                    '${learner.avgScore.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(learner.avgScore),
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey.shade400; // Silver
      case 2:
        return Colors.brown.shade400; // Bronze
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
