# Testing fetch_tray

`fetch_tray` is fully testable and you can test everything from your models, to the requests and your hooks.

## Why test?

The question we get asked a lot is:
Why should I write tests if I am only calling one method, that is tested in the package anyway!

**Our answer:**
To prevent us from making a mistake and keeping everything upgradable.

If you test the values to your very specific result expectation at the point of implementation at this very low level point of the request, you can always be sure in case breaking changes are introduced and you know where to fix, if something breaks after an upgrade!

The tests will be rather simple, but making them is very much adviced!

## Testing models

Here is an example model test:

```dart
import 'package:my_package/data/models/my_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('my_model model test', () {
    test('my_model model is created from json successfully', () async {
      final myModelModel = MyModel.fromJson(<String, dynamic>{
        'id': 1,
        'slug': 'demo-my_model',
        'title': 'Demo my_model',
      });

      // check type
      expect(myModelModel, isA<MyModel>());

      // check data
      expect(myModelModel.id, 1);
      expect(myModelModel.slug, 'demo-my_model');
      expect(myModelModel.title, 'Demo my_model');
    });
  });
}
```

## Testing requests

Testing requests is made easier using our `TrayRequestMock` object.
You can just pass this object to the `makeTrayRequest` method using the `mock` parameter and `fetch_tray` will take care of mocking it correctly.

```dart
import 'package:my_package/data/models/user.dart';
import 'package:my_package/data/requests/fetch_user_request.dart';
import 'package:fetch_tray/fetch_tray.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fetch_user_request', () {
    test('fetch user is performed successfully', () async {
      final response = await makeTrayTestingRequest<User>(
        FetchUserRequest(
          id: 4,
        ),
        TrayRequestMock(
          // here you can pass data json string
          '{ "id": 4, "name": "Test User" }',
          statusCode: 200,
        ),
      );

      // make sure we get the correct result
      expect(response.data, isA<User>());

      // check for correctly set properties
      expect(response.data?.id, 4);
      expect(response.data?.name, 'Test User');
    });
  });
}
```

## Testing your hooks

Testing your hooks would normally be a little bit more annoying, but we provide a special version of the hook, that mocks the request for you.

You can just pass a `TrayRequestMock` prop to the `useMakeTrayRequest` method using the `mock` prop and everything else will be handled by `fetch_tray`.

Here is an example below:

```dart
import 'package:fetch_tray/hooks/use_make_tray_request.dart';
import 'package:fetch_tray/utils/make_tray_request.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_package/data/hooks/use_fetch_user_request.dart';
import 'package:my_package/data/models/user.dart';

import '../mockdata/user_mockdata.dart';

void main() {
  group('useFetchUserRequest', () {
    testWidgets('successfull requests are correctly parsed', (tester) async {
      late TrayRequestHookResponse<User> response;

      // create example widget and use the hook
      await tester.pumpWidget(HookBuilder(
        builder: (context) {
          response = useFetchUserRequest(
            4,
            mock: TrayRequestMock(userMockdata),
          );

          return Container();
        },
      ));

      // in the first stage -> nothing was fetched yet -> so response should be null
      expect(response.data, null);
      expect(response.loading, true);

      await tester.pump(const Duration());

      // make sure we get the correct result
      expect(response.data, isA<User>());

      // check for correctly set properties
      expect(response.data?.id, 4);
      expect(response.data?.name, 'Test user');
      
      await tester.pump(const Duration());
    });

    testWidgets('failed responses are handled correctly', (tester) async {
      late TrayRequestHookResponse<User> hookResult;

      // create example widget and use the hook
      await tester.pumpWidget(HookBuilder(
        builder: (context) {
          hookResult = useFetchUserRequest<User>(
            4,
            mock: TrayRequestMock(
              '{"message": "not allowed"}',
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
      expect(hookResult.error?.statusCode, 410);
    });
  });
}

```
