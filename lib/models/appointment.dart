
import 'package:intl/intl.dart';

class Appointment {
  final String appointmentId;
  final String clientName;
  final String folderNumber;
  final DateTime appointmentDateTime;
  final String? description;
  
  Appointment({
    required this.appointmentId,
    required this.clientName,
    required this.folderNumber,
    required this.appointmentDateTime,
    
    this.description = "No description",
  });

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'clientName': clientName,
      'folderNumber': folderNumber,
      'appointmentDateTime': appointmentDateTime.toIso8601String(),
      'description': description,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      appointmentId: map['appointmentId'] ?? '',
      clientName: map['clientName'] ?? '',
      folderNumber: map['folderNumber'] ?? '',
      appointmentDateTime: DateTime.parse(
          map['appointmentDateTime'] ?? DateTime.now().toIso8601String()),
      description: map['description'] ?? '',
    );
  }
}
 // Get formatted date string (yyyy-MM-dd)
  // String get dateKey => DateFormat('yyyy-MM-dd').format(appointmentDateTime);
  
  // // Get formatted time string (h:mm a)
  // String get timeString => DateFormat('h:mm a').format(thiappointmentDateTime);
  
  // // Check if appointment has description
  // bool get hasdescription => description.isNotEmpty;

  // Copy with method for easy updates
  // Appointment copyWith({
  //   String? clientName,
  //   String? folderNumber,
  //   String? description,
  //   DateTime? appointmentDateTime,
  // }) {
  //   return Appointment(
  //     appointmentId: appo,
  //     clientName: clientName ?? this.clientName,
  //     folderNumber: folderNumber ?? this.folderNumber,
  //     description: description ?? this.description,
  //     appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
  //   );
  // }
