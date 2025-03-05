import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secretary/models/appointment.dart';
import 'package:secretary/utils/notification_service.dart';

class AppointmentDB {
  final CollectionReference _appointmentsCollection =
      FirebaseFirestore.instance.collection('appointments');

  // Create Appointment
  Future<void> addAppointment(Appointment appointment) async {
    try {
      DocumentReference docRef =
          await _appointmentsCollection.add(appointment.toMap());
      await docRef.update({'appointmentId': docRef.id});
    } catch (e) {
      throw Exception('Error adding appointment: $e');
    }
  }

  Future<Appointment?> getAppointment(String appointmentId) async {
    try {
      DocumentSnapshot doc =
          await _appointmentsCollection.doc(appointmentId).get();
      if (doc.exists) {
        return Appointment.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching appointment: $e');
    }
  }

  // Read
  Stream<List<Appointment>> getAppointmentsStream(String userRole) {
    return _appointmentsCollection
        .orderBy("appointmentDateTime", descending: true)
        .snapshots()
        .map((snapshot) {
      final appointments = snapshot.docs.map((doc) {
        return Appointment.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      
      if(userRole!="secretary"){

      _scheduleNotificationsForAppointments(appointments);
      }

      return appointments;
    });
  }

  // Update
  Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _appointmentsCollection
          .doc(appointment.appointmentId)
          .update(appointment.toMap());
    } catch (e) {
      throw Exception('Error updating appointment: $e');
    }
  }

  // Delete
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _appointmentsCollection.doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Error deleting appointment: $e');
    }
  }

  // Schedule
  void _scheduleNotificationsForAppointments(
      List<Appointment> appointments) async {
    final now = DateTime.now();

    //await NotificationService().testScheduledNotification();

    for (final appointment in appointments) {
      final timeDifference = appointment.appointmentDateTime.difference(now);

      if (appointment.appointmentDateTime
          .subtract(const Duration(minutes: 30))
          .isAfter(DateTime.now())) {
        NotificationService().scheduleNotification(
          id: appointment.appointmentId.hashCode,
          title: 'Rendez-vous à venir',
          body: 'rendez-vous avec: ${appointment.clientName}',
          scheduledTime: appointment.appointmentDateTime,
        );
      }
    }
  }
}
