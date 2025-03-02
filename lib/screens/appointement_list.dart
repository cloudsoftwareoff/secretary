import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:secretary/db/appointmentDB.dart';
import 'package:secretary/models/appointment.dart';
import 'package:secretary/screens/widgets/appointment_card.dart';
import 'package:secretary/screens/widgets/date_header.dart';
import 'package:secretary/screens/widgets/search_delegate.dart';
import 'package:secretary/screens/widgets/summary_stats_card.dart';
import 'package:secretary/utils/notification_service.dart';

class AppointmentsList extends StatefulWidget {
  const AppointmentsList({Key? key}) : super(key: key);

  @override
  State<AppointmentsList> createState() => _AppointmentsListState();
}

class _AppointmentsListState extends State<AppointmentsList> {
  final CollectionReference _appointmentsCollection =
      FirebaseFirestore.instance.collection('appointments');

  String _selectedFilter = 'All';
  List<Appointment> appList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchBar,
          ),
        ],
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: AppointmentDB().getAppointmentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No appointments found."));
          }

          final appointments = snapshot.data ?? [];

          // final appointments = snapshot.data!.docs.map((doc) {
          //   return Appointment.fromMap(doc.data() as Map<String, dynamic>);
          // }).toList();

          appList = appointments;

          final filteredAppointments = _applyFilters(appointments);

          return _buildAppointmentsList(filteredAppointments);
        },
      ),
    );
  }

  List<Appointment> _applyFilters(List<Appointment> appointments) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Today':
        return appointments
            .where((appointment) =>
                DateFormat('yyyy-MM-dd')
                    .format(appointment.appointmentDateTime) ==
                DateFormat('yyyy-MM-dd').format(now))
            .toList();
      case 'Tomorrow':
        return appointments
            .where((appointment) =>
                DateFormat('yyyy-MM-dd')
                    .format(appointment.appointmentDateTime) ==
                DateFormat('yyyy-MM-dd')
                    .format(now.add(const Duration(days: 1))))
            .toList();
      case 'This Week':
        return appointments
            .where((appointment) =>
                appointment.appointmentDateTime.isAfter(now) &&
                appointment.appointmentDateTime
                    .isBefore(now.add(const Duration(days: 7))))
            .toList();
      default:
        return appointments;
    }
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    // Group appointments by date
    final Map<String, List<Appointment>> groupedAppointments = {};
    for (var appointment in appointments) {
      final dateKey =
          DateFormat('yyyy-MM-dd').format(appointment.appointmentDateTime);
      groupedAppointments.putIfAbsent(dateKey, () => []).add(appointment);
    }

    final sortedDates = groupedAppointments.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView(
      children: [
        SummaryStatsCard(
          todayCount: groupedAppointments[
                      DateFormat('yyyy-MM-dd').format(DateTime.now())]
                  ?.length ??
              0,
          upcomingCount: appointments
              .where((appointment) =>
                  appointment.appointmentDateTime.isAfter(DateTime.now()))
              .length,
          totalCount: appointments.length,
        ),
        ...sortedDates.map((dateKey) {
          final date = DateTime.parse(dateKey);
          final appointmentsForDate = groupedAppointments[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DateHeader(
                  date: date, appointmentCount: appointmentsForDate.length),
              ...appointmentsForDate.map((appointment) {
                return AppointmentCard(
                  appointment: appointment,
                  onTap: () => _viewAppointmentDetails(context, appointment),
                  onOptionsTap: () =>
                      _showAppointmentOptions(context, appointment),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ],
    );
  }

  void _showFilterDialog() {
    // Store the current filter to restore it if user cancels
    String tempFilter = _selectedFilter;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Filter Appointments"),
        content: StatefulBuilder(
          // Use StatefulBuilder to handle state changes within dialog
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterOptionForDialog('All', tempFilter, (value) {
                  setDialogState(() {
                    tempFilter = value!;
                  });
                }),
                _buildFilterOptionForDialog('Today', tempFilter, (value) {
                  setDialogState(() {
                    tempFilter = value!;
                  });
                }),
                _buildFilterOptionForDialog('Tomorrow', tempFilter, (value) {
                  setDialogState(() {
                    tempFilter = value!;
                  });
                }),
                _buildFilterOptionForDialog('This Week', tempFilter, (value) {
                  setDialogState(() {
                    tempFilter = value!;
                  });
                }),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedFilter = tempFilter; // Apply the selected filter
              });
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptionForDialog(
      String filter, String groupValue, Function(String?) onChanged) {
    return ListTile(
      title: Text(filter),
      leading: Radio<String>(
        value: filter,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
    );
  }

  void _showSearchBar() {
    showSearch(
      context: context,
      delegate: AppointmentSearchDelegate(appointments: appList),
    );
  }

  void _viewAppointmentDetails(BuildContext context, Appointment appointment) {
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
            // Header with close button
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

            // Appointment information with icons
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

// Helper method to build consistent detail rows
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

  void _showAppointmentOptions(BuildContext context, Appointment appointment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ListTile(
            //   leading: const Icon(Icons.edit, color: Colors.blue),
            //   title: const Text("Edit Appointment"),
            //   onTap: () {
            //     Navigator.pop(context);
            //     //! edit screen
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Delete", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, appointment);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Appointment"),
        content:
            const Text("Are you sure you want to delete this appointment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _appointmentsCollection.doc(appointment.appointmentId).delete();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
