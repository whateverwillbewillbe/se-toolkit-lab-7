import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/interaction.dart';
import '../services/lms_service.dart';

/// Screen displaying list of interactions.
class InteractionsScreen extends StatefulWidget {
  const InteractionsScreen({super.key});

  @override
  State<InteractionsScreen> createState() => _InteractionsScreenState();
}

class _InteractionsScreenState extends State<InteractionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LmsService>().loadInteractions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LmsService>().loadInteractions();
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
                    'Error loading interactions',
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

          final interactions = service.interactions;

          if (interactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No interactions found',
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

          return RefreshIndicator(
            onRefresh: () => service.loadInteractions(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: interactions.length,
              itemBuilder: (context, index) {
                final interaction = interactions[index];
                return _InteractionCard(interaction: interaction);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Card widget for displaying an interaction.
class _InteractionCard extends StatelessWidget {
  final Interaction interaction;

  const _InteractionCard({required this.interaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getKindColor(interaction.kind),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getKindIcon(interaction.kind),
            color: Colors.white,
          ),
        ),
        title: Text('Learner #${interaction.learnerId}'),
        subtitle: Text(
          'Item #${interaction.itemId} • ${interaction.kind}',
        ),
        trailing: interaction.score != null
            ? Chip(
                label: Text(
                  '${interaction.score!.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: _getScoreColor(interaction.score!),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              )
            : null,
      ),
    );
  }

  IconData _getKindIcon(String kind) {
    switch (kind.toLowerCase()) {
      case 'view':
        return Icons.visibility;
      case 'submit':
        return Icons.send;
      case 'complete':
        return Icons.check_circle;
      case 'start':
        return Icons.play_arrow;
      default:
        return Icons.info;
    }
  }

  Color _getKindColor(String kind) {
    switch (kind.toLowerCase()) {
      case 'view':
        return Colors.blue;
      case 'submit':
        return Colors.orange;
      case 'complete':
        return Colors.green;
      case 'start':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
