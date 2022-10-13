import 'package:fetch_tray/fetch_tray.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mockdata/models/mock_user.dart';

import '../mockdata/requests/fetch_mock_user_request.dart';

void main() {
  group('useMakeTrayRequest basic', () {
    testWidgets('successful requests are correctly parsed', (tester) async {
      late MockUser? response;
      late HookElement element;

      // create a mock request
      final mockRequest = FetchMockUserRequest();

      // create example widget and use the hook
      await tester.pumpWidget(HookBuilder(
        builder: (context) {
          element = context as HookElement;
          final hookResult =
              useMakeTrayRequest<TrayRequest, MockUser, TrayRequestMetadata>(
            mockRequest,
            mock: TrayRequestMock('{"id": 1, "email": "test@example.com"}'),
          );

          response = hookResult.data;

          return Container();
        },
      ));

      // in the first stage -> nothing was fetched yet -> so response should be null
      expect(response, null);

      await tester.pump(const Duration());

      // make sure we get the correct result
      expect(response, isA<MockUser>());

      // check for correctly set properties
      expect(response?.id, 1);
      expect(response?.email, 'test@example.com');
      expect(element.dirty, false);

      await tester.pump(const Duration());
    });

    testWidgets('loading state is set correctly', (tester) async {
      late TrayRequestHookResponse<TrayRequest, MockUser, TrayRequestMetadata>
          hookResult;

      // create a mock request
      final mockRequest = FetchMockUserRequest();

      // create example widget and use the hook
      await tester.pumpWidget(HookBuilder(
        builder: (context) {
          hookResult =
              useMakeTrayRequest<TrayRequest, MockUser, TrayRequestMetadata>(
            mockRequest,
            mock: TrayRequestMock('{"id": 1, "email": "test@example.com"}'),
          );

          return Container();
        },
      ));

      // check if loading state is in loading
      expect(hookResult.loading, true);

      await tester.pump(const Duration());

      // make sure we get the correct result
      expect(hookResult.data, isA<MockUser>());

      // make sure hook result is not loading anymore
      expect(hookResult.loading, false);

      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('failed responses are handled correctly', (tester) async {
      late TrayRequestHookResponse<TrayRequest, MockUser, TrayRequestMetadata>
          hookResult;

      // create a mock request
      final mockRequest = FetchMockUserRequest();

      // create example widget and use the hook
      await tester.pumpWidget(HookBuilder(
        builder: (context) {
          hookResult =
              useMakeTrayRequest<TrayRequest, MockUser, TrayRequestMetadata>(
            mockRequest,
            mock: TrayRequestMock(
              '{"message": "not allowed", "errors": ["no access to this resource"]}',
              statusCode: 410,
            ),
          );

          return Container();
        },
      ));

      // make sure the response has to time to be injected
      await tester.pump(const Duration());

      // make sure the data and loading states are disabled
      expect(hookResult.loading, false);
      expect(hookResult.data, null);

      // make sure we get the correct error result object
      expect(hookResult.error, isA<TrayRequestError>());

      // check the error properties
      expect(hookResult.error?.message, 'not allowed');
      expect(hookResult.error?.errors, ['no access to this resource']);
      expect(hookResult.error?.statusCode, 410);
    });
  });
}
