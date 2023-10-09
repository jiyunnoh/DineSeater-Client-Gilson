import 'package:flutter_test/flutter_test.dart';
import 'package:dineseater_client_gilson/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Confirm2ViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
