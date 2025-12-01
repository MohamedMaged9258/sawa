SAWA Fitness

SAWA Fitness is a comprehensive, multi-sided marketplace application built with Flutter that bridges the gap between fitness enthusiasts and service providers. It connects members with gyms, nutritionists, and healthy restaurants in a single, unified ecosystem.

📱 Features by Role

The app provides four distinct experiences based on the user's role:

🏋️ Member

Gym Booking: Browse gyms, view pricing, and book workout sessions.

Nutrition: Consult with certified nutritionists and receive personalized meal plans.

Healthy Dining: Order meals from verified healthy restaurants.

Dashboard: Track gym visits, orders, and active plans.

🏢 Gym Owner

Management: Add and manage gym locations and facilities.

Team: Manage coaches and assign them to specific gyms.

Analytics: Track revenue, active members, and booking statistics.

🥗 Restaurant Owner

Menu Control: Create and manage healthy meal options.

Order Management: Real-time order tracking (Pending → Preparing → Completed).

Business Insights: Monitor daily revenue and order volume.

🍎 Nutritionist

Client Management: Track client progress and goals.

Meal Planning: Create detailed weekly nutrition plans.

Consultations: Schedule and manage virtual or in-person sessions.

🛠️ Tech Stack

Framework: Flutter (Dart)

State Management: Provider

Backend: Firebase

Authentication: Email/Password via Firebase Auth

Database: Cloud Firestore (NoSQL)

Storage: Firebase Storage (Images)

Architecture: Layered Architecture (Presentation, Domain/Providers, Data/Models)

🚀 Getting Started

Prerequisites

Flutter SDK (3.10.0 or higher)

Dart SDK (3.0.0 or higher)

A Firebase Project

Installation

Clone the repository

git clone [https://github.com/mohamedmaged9258/sawa.git](https://github.com/mohamedmaged9258/sawa.git)
cd sawa


Install dependencies

flutter pub get


Configure Firebase
This project uses flutterfire_cli. Ensure you have the Firebase CLI installed and logged in.

flutterfire configure


Select your project ID (sawafulldatabase) when prompted.

Run the app

flutter run


📂 Project Structure

lib/
├── core/            # App-wide constants and configs
├── presentation/    # UI Layer
│   ├── models/      # Data models (JSON serialization)
│   ├── providers/   # State management & Business logic
│   ├── screens/     # UI Screens organized by feature
│   └── widgets/     # Reusable components
└── main.dart        # Entry point & Theme configuration


🧪 Testing

We maintain a suite of Unit, Widget, and Integration tests.

To run all tests:

flutter test


For specific test suites:

# Unit Tests
flutter test test/unit/

# Widget Tests
flutter test test/widget/


🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

Fork the Project

Create your Feature Branch (git checkout -b feature/AmazingFeature)

Commit your Changes (git commit -m 'Add some AmazingFeature')

Push to the Branch (git push origin feature/AmazingFeature)

Open a Pull Request

📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
