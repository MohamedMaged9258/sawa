@echo off
echo Running unit tests...
dart test/unit/auth_provider_test.dart
dart test/unit/member_provider_test.dart
echo Running integration tests...
dart test/integration/meal_plan_flow_test.dart
echo All tests completed.