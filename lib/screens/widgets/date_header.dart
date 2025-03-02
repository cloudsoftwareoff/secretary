import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHeader extends StatelessWidget {
  final DateTime date;
  final int appointmentCount;

  const DateHeader({
    super.key,
    required this.date,
    required this.appointmentCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isTomorrow = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));

    String headerText;
    if (isToday) {
      headerText = "Aujourd'hui";
    } else if (isTomorrow) {
      headerText = "Demain";
    } else {
      headerText = DateFormat('EEEE, MMMM d').format(date);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isToday
                  ? theme.colorScheme.secondary
                  : isTomorrow
                      ? Colors.green
                      : theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isToday ? Icons.today : isTomorrow ? Icons.event : Icons.event_note,
                  size: 16,
                  color: isToday || isTomorrow ? Colors.white : theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  headerText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isToday || isTomorrow ? Colors.white : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "$appointmentCount rendez-vous",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}