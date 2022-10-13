import 'package:flutter_test/flutter_test.dart';

import '../mockdata/requests/update_mock_user_request.dart';

void main() {
  group('request_body', () {
    /// it should be possible to send a url with placeholders
    /// and params. `getUrlWithParams()` should replace these path placeholders.
    test('map is generated with correct values', () async {
      final requestBody = UpdateMockUserRequestBody(
        id: 3,
        email: 'test@example.com',
      );

      expect(await requestBody.getMap(), {
        'id': '3',
        'email': 'test@example.com',
      });
    });

    /// it should be possible to send a body, that is a list
    test('list is generated with correct values', () async {
      // TODO: add test here
    });

    /// it should be possible to send a body, that is just a simple scalar
    test('body scalar works correctly', () async {
      // TODO: add test here
    });
  });
}
