import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:secretary/models/appointment.dart';

class AppointmentSearchDelegate extends SearchDelegate<String> {
  final List<Appointment> appointments;

  AppointmentSearchDelegate({required this.appointments});

  @override
  String get searchFieldLabel => 'Rechercher des rendez-vous...';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        titleTextStyle: TextStyle(
          color: theme.textTheme.titleLarge?.color,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: theme.hintColor),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        tooltip: 'Effacer la recherche',
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      tooltip: 'Retour',
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = appointments
        .where((appointment) =>
            appointment.clientName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildAppointmentList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? appointments
        : appointments
            .where((appointment) => appointment.clientName
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();

    if (suggestions.isEmpty) {
      if (query.isEmpty) {
        return _buildInitialSearchState(context);
      } else {
        return _buildEmptyState(context);
      }
    }

    return _buildAppointmentList(context, suggestions);
  }

  Widget _buildAppointmentList(
      BuildContext context, List<Appointment> appointmentList) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: appointmentList.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final appointment = appointmentList[index];
        final now = DateTime.now();
        final isUpcoming = appointment.appointmentDateTime.isAfter(now);
        final isPast = appointment.appointmentDateTime.isBefore(now);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              query = appointment.clientName;
              showResults(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isUpcoming
                          ? Colors.green[50]
                          : isPast
                              ? Colors.grey[200]
                              : Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        isUpcoming
                            ? Icons.event_available
                            : isPast
                                ? Icons.event_busy
                                : Icons.event,
                        color: isUpcoming
                            ? Colors.green
                            : isPast
                                ? Colors.grey
                                : Colors.blue,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Appointment details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.clientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Theme.of(context).hintColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('EEE, MMM d, yyyy')
                                  .format(appointment.appointmentDateTime),
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Theme.of(context).hintColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('h:mm a')
                                  .format(appointment.appointmentDateTime),
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (appointment.folderNumber.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.folder,
                                size: 14,
                                color: Theme.of(context).hintColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Dossier: ${appointment.folderNumber}",
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Theme.of(context).hintColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun rendez-vous trouvé',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de rechercher avec un terme différent',
            style: TextStyle(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialSearchState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Recherche de rendez-vous',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Entrez le nom du client',
            style: TextStyle(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
