# Testing Guide

## Overview
This project includes unit tests, widget tests, and integration tests to ensure the quality and reliability of the application.

## Test Structure
- `test/unit/` - Unit tests for individual components and providers
- `test/widget/` - Widget tests for UI components
- `test/integration/` - Integration tests for complete workflows

## Running Tests

### Prerequisites
Make sure you have Flutter and Dart properly installed and configured.

### Running Unit Tests
```bash
flutter test test/unit/auth_provider_test.dart
flutter test test/unit/member_provider_test.dart
```

### Running Widget Tests
```bash
flutter test test/widget/login_screen_test.dart
flutter test test/widget/register_screen_test.dart
flutter test test/widget/member_home_screen_test.dart
flutter test test/widget/custom_widgets_test.dart
```

### Running Integration Tests
```bash
flutter test test/integration/auth_flow_test.dart
flutter test test/integration/meal_plan_flow_test.dart
```

### Running All Tests
```bash
flutter test
```

## Mock Generation
The mock files are automatically generated using Mockito annotations. If you make changes to the annotations, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Troubleshooting

### Import Issues
If you encounter import issues with `.mocks.dart` files:
1. Ensure all mock files exist in the correct locations
2. Run the build_runner command to regenerate mocks
3. Check that analysis_options.yaml excludes mock files from analysis

### Android Studio Issues
If Android Studio shows errors in test files:
1. Invalidate caches and restart Android Studio
2. Ensure the Dart and Flutter plugins are properly installed
3. Check that the project SDK is correctly configured