import 'package:fetch_tray/contracts/tray_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tray_request', () {
    /// it should be possible to send a url with placeholders
    /// and params. `getUrlWithParams()` should replace these path placeholders.
    test('url with path params is created successfully', () async {
      const exampleUrl = 'https://www.example.com/users/:id';

      final request = TrayRequest(
        url: exampleUrl,
        params: {'id': '1'},
      );

      expect(
          await request.getUrlWithParams(), 'https://www.example.com/users/1');
    });

    /// it should be possible to send params, that are not in the url path
    /// in this case they will just be added as queryParams
    test('url with query params is created successfully', () async {
      const exampleUrl = 'https://www.example.com/users/';

      final request = TrayRequest(
        url: exampleUrl,
        params: {'orderBy': 'name'},
      );

      expect(await request.getUrlWithParams(),
          'https://www.example.com/users/?orderBy=name');
    });

    /// it should be possible to have a combination of path and query params
    /// if a param was already used as a path param, it should not be used in query
    test('url with query params and path params is created successfully',
        () async {
      const exampleUrl = 'https://www.example.com/users/:id';

      final request = TrayRequest(
        url: exampleUrl,
        params: {
          'id': '1',
          'orderBy': 'name',
        },
      );

      expect(
        await request.getUrlWithParams(),
        'https://www.example.com/users/1?orderBy=name',
      );
    });
  });
}
