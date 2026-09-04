# Taskify (To-Do List App)

Taskify is a feature-rich, robust To-Do List and Routine Management application built with Flutter. It utilizes modern app development practices, integrating powerful tools for state management, local storage, cloud synchronization, and user authentication.

##  Features

- **Authentication:** Secure login and registration using Firebase Auth and Google Sign-In.
- **Task Management:** Create, read, update, and delete tasks seamlessly.
- **Routine Management:** Manage your daily routines and habits.
- **Calendar View:** Keep track of tasks and schedules easily with an integrated calendar.
- **Notifications:** Set up local notifications and reminders for your tasks.
- **Offline Support:** Local caching and data persistence using SQFlite.
- **Cloud Sync:** Synchronizes user data to Cloud Firestore.
- **Localization:** Supports multiple languages and translations.
- **State Management:** Fully reactive state management using GetX.

##  Tech Stack & Libraries

- **Framework:** [Flutter](https://flutter.dev/) (SDK: ^3.9.2)
- **State Management & Routing:** [GetX](https://pub.dev/packages/get)
- **Backend & Auth:** Firebase Core, Firebase Auth, Cloud Firestore, Google Sign-In
- **Local Database:** SQFlite
- **UI Components:** `table_calendar`, `floating_bottom_bar`, `google_fonts`
- **Notifications:** `flutter_local_notifications`, `timezone`
- **Network Checking:** `connectivity_plus`, `internet_connection_checker_plus`

## Folder Structure

The project follows a clean, modular architecture:

```text
lib/
├── core/       # App-wide core functionalities (Localization, themes, constants)
├── data/       # Data layer (Models, services, local db, controllers)
├── modules/    # UI screens and modular features (auth, dashboard, task, routine, etc.)
├── widgets/    # Reusable, shared UI components
└── main.dart   # Application entry point
```

## Getting Started

To run this project locally, follow these steps:

### Prerequisites

- Flutter SDK installed on your machine.
- Dart installed.
- Android Studio or Xcode for emulator/simulator.
- A Firebase project configured for Android/iOS with `google-services.json` and `GoogleService-Info.plist` (if not already included).

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd to_do_list_app
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## License

This project is licensed under the MIT License.
