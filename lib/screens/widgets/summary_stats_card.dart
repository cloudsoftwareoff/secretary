import 'package:flutter/material.dart';

class SummaryStatsCard extends StatelessWidget {
  final int todayCount;
  final int upcomingCount;
  final int totalCount;

  const SummaryStatsCard({
    super.key,
    required this.todayCount,
    required this.upcomingCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Résumé du rendez-vous",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSummaryItem(context, Icons.today, Colors.blue,
                    "Aujourd'hui", todayCount.toString()),
                _buildSummaryItem(context, Icons.event, Colors.green,
                    "Cette semaine", upcomingCount.toString()),
                _buildSummaryItem(context, Icons.event_note, Colors.purple,
                    "Totale", totalCount.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, IconData icon, Color color,
      String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
