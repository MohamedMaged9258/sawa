# SAWA Fitness App Testing

This directory contains comprehensive tests for the SAWA Fitness application.

## Test Structure

```
test/
├── unit/              # Unit tests for individual components
├── widget/            # Widget tests for UI components
├── integration/       # Integration tests for user flows
├── test_runner.dart   # Test runner to execute all tests
└── README.md          # This file
```

## Test Categories

### Unit Tests
- `auth_provider_test.dart` - Tests for the AuthProvider class
- `member_provider_test.dart` - Tests for the MemberProvider class

### Widget Tests
- `login_screen_test.dart` - Tests for the LoginScreen UI
- `register_screen_test.dart` - Tests for the RegisterScreen UI
- `member_home_screen_test.dart` - Tests for the MemberHomeScreen UI
- `custom_widgets_test.dart` - Tests for custom UI components

### Integration Tests
- `auth_flow_test.dart` - Tests for the complete authentication flow

## Running Tests

To run all tests:

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/unit/auth_provider_test.dart
```

To run tests with coverage:

```bash
flutter test --coverage
```

## Test Coverage

The tests cover:

1. **Authentication Flow**
   - Login screen validation
   - Registration screen validation
   - Password reset functionality
   - Navigation between auth screens

2. **UI Components**
   - Custom button behavior
   - Custom text field validation
   - Screen layouts and navigation

3. **Data Providers**
   - AuthProvider state management
   - MemberProvider data fetching

4. **User Flows**
   - Complete authentication journey
   - Navigation between different sections
   - Error handling and user feedback

## Mocking

The tests use Mockito for mocking dependencies:
- Firebase Authentication
- Cloud Firestore
- Other external services

## Continuous Integration

Tests are designed to run in CI/CD pipelines to ensure code quality and prevent regressions.