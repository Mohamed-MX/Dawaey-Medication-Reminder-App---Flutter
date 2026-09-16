 <h1>Dawaey-Medication-Reminder-App 💊</h1>
A comprehensive Flutter application designed to help patients and caregivers track and manage medication schedules effectively. The app features a role-based system for both patients and their caregivers to ensure medication adherence.

## 📱 Screenshots
 <tr>
<img width="250" height="550" alt="WhatsApp Image 2026-09-16 at 4 27 34 PM" src="https://github.com/user-attachments/assets/009f3ebf-b87e-4780-aa4b-e68c7f073b33" />
<img width="250" height="550" alt="WhatsApp Image 2026-09-16 at 6 52 16 PM" src="https://github.com/user-attachments/assets/48d54c13-85f1-45c4-9f4a-e04d8391657b" />
<img width="250" height="550" alt="WhatsApp Image 2026-09-16 at 6 52 17 PM" src="https://github.com/user-attachments/assets/f27e7c9e-2513-4c1e-9153-a33d23ac8b63" />



## Features

*   **Role-Based Access**: Support for both Patient and Caregiver accounts. Caregivers can monitor and manage medications for their linked patients.
*   **Authentication**: Secure login and registration using Firebase Authentication.
*   **Medication Management**: Add, edit, and delete medications with specific dosages, frequencies, and intake times.
*   **Dose Tracking**: Track whether a medication dose was taken, missed, or is pending.
*   **Local Notifications**: Receive timely reminders for upcoming medication doses using `flutter_local_notifications`.
*   **Reports & Statistics**: View daily, weekly, monthly, and yearly reports on medication adherence with visual charts.
*   **History Logs**: View past medication records and schedules.
*   **Offline Support/Local Cache**: Uses Hive for local caching where applicable.

## Tech Stack & Packages

*   **Framework**: Flutter (SDK ^3.10.4)
*   **State Management**: BLoC / Cubit (`flutter_bloc`)
*   **Backend / Database**: Firebase (Auth, Firestore)
*   **Local Storage**: Hive (`hive`, `hive_flutter`)
*   **Notifications**: `flutter_local_notifications`, `timezone`
*   **UI / Components**: 
    *   `table_calendar` & `date_picker_timeline` for date selection.
    *   `month_year_picker` for monthly reports.
    *   `flutter_svg` for scalable vector icons.
    *   `image_picker` for profile pictures.
*   **Localization**: `flutter_localizations` (Arabic RTL UI)

## Getting Started

### Prerequisites

*   Flutter SDK installed (version 3.10.4 or higher).
*   A connected device or emulator for testing.
*   Firebase project setup (requires placing your `google-services.json` / `GoogleService-Info.plist` in the appropriate android/ios directories).

### Installation

1.  **Clone the repository** (if applicable).
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Environment Variables**:
    *   Ensure you have a `.env` file in the root directory if the app relies on specific environment keys (e.g., for APIs).
4.  **Run the app**:
    ```bash
    flutter run
    ```

## Architecture

The project follows a **Feature-Driven Architecture** to maintain strict separation of concerns, scalability, and clean code principles. The codebase is organized primarily by features, with each feature encapsulating its own architectural layers.

### Folder Structure
*   `lib/Fetures/` - Contains all the core domains of the app (e.g., Auth, medications, reports, patient, caregiver).
*   `lib/core/` - Shared utilities, generic components, themes, routing, and app-wide configurations.
*   `lib/services/` - Global services and initializations (like notifications or global Firebase services).

### Internal Feature Layers
Inside most features within the `lib/Fetures/` directory, the code is structured into layers:
*   **presentation/**: 
    *   `view/`: Screens and pages.
    *   `widgets/`: UI components specific to the feature.
    *   State Management (e.g., `cubit/` or `manager/`): BLoC or Cubit classes for state management.
*   **data/**: 
    *   `models/`: Data structures and serialization logic.
    *   `repositories/`: Abstractions over data sources (local caching and remote Firebase calls).
*   **services/**: Feature-specific business logic or API interactions.

### Key Features Modules
*   **Auth**: Authentication, user roles, login, signup, and onboarding flow.
*   **medications**: Medication tracking, scheduling, and UI for adding or managing meds.
*   **patient** & **caregiver**: Distinct dashboards and flows tailored for the two user roles.
*   **reports**: Statistics calculation, data aggregation, and chart plotting for adherence.
*   **history**: Historical logs and past medication records.
