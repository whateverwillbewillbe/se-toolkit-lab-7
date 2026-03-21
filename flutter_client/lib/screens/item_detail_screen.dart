import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../services/lms_service.dart';
import 'analytics_screen.dart';

/// Screen displaying details of a lab or task.
class ItemDetailScreen extends StatefulWidget {
  final Item lab;

  const ItemDetailScreen({super.key, required this.lab});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load items if not already loaded
    final service = context.read<LmsService>();
    if (service.items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        service.loadItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lab = widget.lab;

    return Scaffold(
      appBar: AppBar(
        title: Text(lab.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<LmsService>(
        builder: (context, service, child) {
          final tasks = service.getTasksForLab(lab.id);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lab info card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.school,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Laboratory Work',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        if (lab.description != null &&
                            lab.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            lab.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ID: ${lab.id}',
                              style:
                                  Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tasks section
                Row(
                  children: [
                    Icon(
                      Icons.task,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tasks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('${tasks.length}'),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (tasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.task_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No tasks found',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _TaskCard(task: task, labId: lab.id);
                    },
                  ),

                const SizedBox(height: 24),

                // Analytics button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnalyticsScreen(labId: lab.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.analytics),
                    label: const Text('View Analytics'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Card widget for displaying a task.
class _TaskCard extends StatelessWidget {
  final Item task;
  final int labId;

  const _TaskCard({required this.task, required this.labId});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.assignment,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: task.description != null && task.description!.isNotEmpty
            ? Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to task detail or analytics
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalyticsScreen(labId: labId, taskId: task.id),
            ),
          );
        },
      ),
    );
  }
}
