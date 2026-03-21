import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/learner.dart';
import '../services/lms_service.dart';

/// Screen displaying list of learners.
class LearnersScreen extends StatefulWidget {
  const LearnersScreen({super.key});

  @override
  State<LearnersScreen> createState() => _LearnersScreenState();
}

class _LearnersScreenState extends State<LearnersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LmsService>().loadLearners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learners'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LmsService>().loadLearners();
            },
          ),
        ],
      ),
      body: Consumer<LmsService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.error != null) {
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
                    'Error loading learners',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      service.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }

          final learners = service.learners;

          if (learners.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No learners found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check your connection and try again',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // Group learners by student group
          final groupedLearners = <String, List<Learner>>{};
          for (final learner in learners) {
            groupedLearners.putIfAbsent(learner.studentGroup, () => []);
            groupedLearners[learner.studentGroup]!.add(learner);
          }

          return RefreshIndicator(
            onRefresh: () => service.loadLearners(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedLearners.length,
              itemBuilder: (context, index) {
                final group = groupedLearners.keys.elementAt(index);
                final groupLearners = groupedLearners[group]!;

                return _GroupCard(
                  groupName: group,
                  learners: groupLearners,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Card widget for displaying a group of learners.
class _GroupCard extends StatelessWidget {
  final String groupName;
  final List<Learner> learners;

  const _GroupCard({
    required this.groupName,
    required this.learners,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.groups,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Group: $groupName',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Chip(
                  label: Text('${learners.length}'),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...learners.map((learner) => ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      learner.externalId.substring(0, 1).toUpperCase(),
                    ),
                  ),
                  title: Text('ID: ${learner.externalId}'),
                  subtitle: Text('Learner #${learner.id}'),
                )),
          ],
        ),
      ),
    );
  }
}
