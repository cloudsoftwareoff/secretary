import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:secretary/db/appointmentDB.dart';
import 'package:secretary/models/appointment.dart';

class AddAppointment extends StatefulWidget {
  const AddAppointment({super.key});

  @override
  _AddAppointmentState createState() => _AddAppointmentState();
}

class _AddAppointmentState extends State<AddAppointment> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _folderNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _addAppointment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await AppointmentDB().addAppointment(Appointment(
            appointmentId: _selectedDate.toIso8601String(),
            clientName: _clientNameController.text,
            folderNumber: _folderNumberController.text,
            appointmentDateTime: _selectedDate,
            description: _descriptionController.text));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Rendez-vous ajouté avec succès"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        _clientNameController.clear();
        _folderNumberController.clear();
        _descriptionController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de l'ajout du rendez-vous : $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).colorScheme.primary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un rendez-vous"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Icon(
                  Icons.calendar_today,
                  size: 40,
                  color: theme.colorScheme.secondary,
                ),
                SizedBox(height: 16),
                Text(
                  "Créer un nouveau rendez-vous",
                  style: theme.textTheme.headlineSmall,
                ),
                Text(
                  "Remplissez les détails ci-dessous pour planifier un nouveau rendez-vous",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32),

                // Client information section
                Text(
                  "INFORMATIONS DU CLIENT",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),

                // Client name field
                TextFormField(
                  controller: _clientNameController,
                  decoration: InputDecoration(
                    labelText: "Nom du client",
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: "Entrez le nom complet du client",
                  ),
                  validator: (value) => value!.isEmpty
                      ? "Veuillez entrer le nom du client"
                      : null,
                ),
                SizedBox(height: 16),

                // Folder number field
                TextFormField(
                  controller: _folderNumberController,
                  decoration: InputDecoration(
                    labelText: "Numéro de dossier",
                    prefixIcon: Icon(Icons.folder_outlined),
                    hintText: "Entrez le numéro de dossier du client",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty
                      ? "Veuillez entrer le numéro de dossier"
                      : null,
                ),
                SizedBox(height: 24),

                // Appointment details section
                Text(
                  "DÉTAILS DU RENDEZ-VOUS",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),

                // Date and time card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.event,
                              color: theme.colorScheme.secondary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Date et Heure",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Date et Heure sélectionnées",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          DateFormat('EEE, d MMM yyyy · HH:mm')
                                              .format(_selectedDate),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.calendar_month,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _pickDateTime,
                            icon: Icon(Icons.edit_calendar),
                            label: Text("Changer la date et l'heure"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Notes field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    prefixIcon: Icon(Icons.note_outlined),
                    hintText: "Ajoutez des notes supplémentaires (facultatif)",
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _addAppointment,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.add),
                    label: Text(_isLoading
                        ? "ENREGISTREMENT..."
                        : "AJOUTER UN RENDEZ-VOUS"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
