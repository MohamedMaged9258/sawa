import 'package:flutter_test/flutter_test.dart';
import 'unit/auth_provider_test.dart' as auth_provider_test;
import 'unit/member_provider_test.dart' as member_provider_test;
import 'widget/login_screen_test.dart' as login_screen_test;
import 'widget/register_screen_test.dart' as register_screen_test;
import 'widget/member_home_screen_test.dart' as member_home_screen_test;
import 'widget/custom_widgets_test.dart' as custom_widgets_test;
import 'integration/auth_flow_test.dart' as auth_flow_test;

void main() {
  group('All Tests', () {
    // Unit Tests
    group('Unit Tests', () {
      auth_provider_test.main();
      member_provider_test.main();
    });

    // Widget Tests
    group('Widget Tests', () {
      login_screen_test.main();
      register_screen_test.main();
      member_home_screen_test.main();
      custom_widgets_test.main();
    });

    // Integration Tests
    group('Integration Tests', () {
      auth_flow_test.main();
    });
  });
}