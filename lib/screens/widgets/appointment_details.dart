import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:secretary/models/appointment.dart';

void showAppointmentDetails(BuildContext context, Appointment appointment) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Détails du rendez-vous",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                _buildDetailRow(
                  context,
                  Icons.person,
                  "Client",
                  appointment.clientName,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  Icons.event,
                  "Date",
                  DateFormat('EEE, MMM d, yyyy')
                      .format(appointment.appointmentDateTime),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  Icons.access_time,
                  "Temps",
                  DateFormat('h:mm a')
                      .format(appointment.appointmentDateTime),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  Icons.folder,
                  "Dossier",
                  appointment.folderNumber,
                ),
                if (appointment.description != null &&
                    appointment.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    Icons.description,
                    "Description",
                    appointment.description!,
                    isDescription: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDetailRow(
    BuildContext context, IconData icon, String label, String value,
    {bool isDescription = false}) {
  return Row(
    crossAxisAlignment:
        isDescription ? CrossAxisAlignment.start : CrossAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight:
                        isDescription ? FontWeight.normal : FontWeight.w500,
                  ),
              maxLines: isDescription ? 4 : 1,
              overflow:
                  isDescription ? TextOverflow.ellipsis : TextOverflow.clip,
            ),
          ],
        ),
      ),
    ],
  );
}