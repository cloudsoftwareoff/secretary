# EJ Agency

![EJ Agency Logo](assets/images/EJ-logo.png)


# Secretary - Appointment Management App

**Secretary** is a Flutter-based appointment management application designed to help users efficiently schedule, track, and manage appointments. It includes features like adding appointments, filtering, searching, and viewing detailed statistics. The app is integrated with **Firebase Firestore** for real-time data storage and retrieval.

---

## Features

- **User Authentication**: Role-based access (e.g., secretary, director).
- **Appointment Management**:
  - Add new appointments with client details, date, time, and description.
  - Edit or delete existing appointments.
- **Filter Appointments**:
  - Filter by "Today", "Tomorrow", "This Week", or "All".
- **Search Appointments**: Quickly find appointments by client name or folder number.
- **Detailed Statistics**:
  - View the number of appointments for today, upcoming, and total.
- **Responsive UI**: Built with Flutter for a smooth and intuitive user experience.
- **Real-Time Updates**: Powered by Firebase Firestore for seamless data synchronization.

---

## Screenshots

| Home Screen | Add Appointment | Appointment Details |
|-------------|-----------------|---------------------|
| ![Home Screen](/home.png) | ![Add Appointment](/add_appointment.png) | ![Appointment Details](/details.png) |

---

## Technologies Used

- **Frontend**: Flutter
- **Backend**: Firebase Firestore
- **State Management**: Built-in Flutter State Management
- **Dependencies**:
  - `cloud_firestore`: For real-time database operations.
  - `intl`: For date and time formatting.
  - `shimmer`: For loading animations.
  - `flutter_spinkit`: For additional loading animations.

---

## Installation

### Prerequisites

- Flutter SDK installed (version 3.0 or higher).
- Firebase project set up with Firestore enabled.
- Android Studio or VS Code with Flutter plugin installed.

### Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/cloudsoftwareoff/secretary-app.git
   cd secretary-app
   ```

2. Install dependencies:

    ```bash
    flutter pub get
    ```