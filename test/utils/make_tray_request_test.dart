import 'package:fetch_tray/fetch_tray.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../mockdata/models/mock_user.dart';

import '../mockdata/requests/create_mock_user_request.dart';
import '../mockdata/requests/delete_mock_user_request.dart';
import '../mockdata/requests/fetch_mock_user_custom_client_request.dart';
import '../mockdata/requests/fetch_mock_user_list_request.dart';
import '../mockdata/requests/fetch_mock_user_request.dart';
import '../mockdata/requests/update_mock_user_request.dart';
import 'make_tray_request_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('makeTrayRequest basics', () {
    /// it should be possible to make a request with a single entry as a result
    /// (think a request returning a single blog post)
    test('request with single model result returns model', () async {
      // create the mock client
      final mockClient = MockClient();

      // create a mock request
      final mockRequest = FetchMockUserRequest();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(mockClient.get(
        Uri.parse(mockRequest.url),
        headers: {},
      )).thenAnswer(
        (_) async => http.Response(
          '{"id": 1, "email": "test@example.com"}',
          200,
        ),
      );

      // try to make a request to an example url
      final exampleUser = await makeTrayRequest<MockUser>(
        mockRequest,
        client: mockClient,
      );

      // check for correct result type
      expect(exampleUser.data, isA<MockUser>());

      // check for correctly set properties
      expect(exampleUser.data?.id, 1);
      expect(exampleUser.data?.email, 'test@example.com');
    });

    /// it should be possible to overwrite the url
    /// this is needed for cases, where some requests are of the same type
    /// but have different source urls.
    /// The clean approach would be to create a completely new request input object
    /// but in some specific cases this could be too much overhead or not possible
    test('overwriting the url works', () async {
      const exampleUrl = 'https://www.example.com/adifferenturl';

      // create the mock client
      final mockClient = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(mockClient.get(
        Uri.parse(exampleUrl),
        headers: {},
      )).thenAnswer(
        (_) async => http.Response(
          '{"id": 1, "email": "test@example.com"}',
          200,
        ),
      );

      // try to make a request to an example url
      final exampleUser = await makeTrayRequest<MockUser>(
        FetchMockUserRequest(
          url: exampleUrl,
        ),
        client: mockClient,
      );

      // check for correctly set properties
      expect(exampleUser.data?.id, 1);
      expect(exampleUser.data?.email, 'test@example.com');
    });

    /// Our makeTrayRequest method should not only work with results,
    /// that return a single entry, but also with a list of entries
    /// (think of a blog entry listing)
    test('list response returns a list of the model', () async {
      const exampleUrl = 'https://www.example.com/listofmodels';

      // create the mock client
      final mockClient = MockClient();

      // return a list of items
      when(mockClient.get(
        Uri.parse(exampleUrl),
        headers: {},
      )).thenAnswer(
        (_) async => http.Response(
          '[{"id": 1, "email": "test1@example.com"}, {"id": 2, "email": "test2@example.com"}]',
          200,
        ),
      );

      // make the request using the list request
      final exampleUser = await makeTrayRequest<List<MockUser>>(
        FetchMockUserListRequest(
          url: exampleUrl,
        ),
        client: mockClient,
      );

      // check for correct result type
      expect(exampleUser.data, isA<List<MockUser>>());

      // check the item entries
      expect(exampleUser.data?[0].email, 'test1@example.com');
      expect(exampleUser.data?[1].email, 'test2@example.com');
    });
  });

  /// tests concerning other request methods
  group('makeTrayRequest request methods', () {
    /// It should be possible to make post requests with a body
    test('make post request', () async {
      // create the mock client
      final mockClient = MockClient();

      // create a mock request body
      final mockRequestBody = CreateMockUserRequestBody(
        email: 'test3@example.com',
      );

      // create a mock request
      final mockRequest = CreateMockUserRequest(
        body: mockRequestBody,
      );

      // mock request response
      when(mockClient.post(
        Uri.parse(mockRequest.url),
        body: argThat(contains('test3@example.com'), named: 'body'),
        headers: {},
      )).thenAnswer(
        (_) async => http.Response(
          '{"id": 3, "email": "test3@example.com"}',
          200,
        ),
      );

      // try to make a request to an example url
      final exampleUser = await makeTrayRequest<MockUser>(
        mockRequest,
        client: mockClient,
      );

      // check for correct result type
      expect(exampleUser.data, isA<MockUser>());

      // check for correctly set properties
      expect(exampleUser.data?.id, 3);
      expect(exampleUser.data?.email, 'test3@example.com');
    });

    /// It should be possible to make put requests with a body
    test('make put request', () async {
      // create the mock client
      final mockClient = MockClient();

      // create a mock request body
      final mockRequestBody = UpdateMockUserRequestBody(
        id: 4,
        email: 'test4@example.com',
      );

      // create a mock request
      final mockRequest = UpdateMockUserRequest(
        body: mockRequestBody,
      );

      // mock request response
      when(mockClient.put(
        Uri.parse(mockRequest.url),
        // body: {'id': '4', 'email': 'test4@example.com'},
        body: argThat(contains('test4@example.com'), named: 'body'),
        headers: {},
      )).thenAnswer(
        (_) async => http.Response(
          '{"id": 4, "email": "test4@example.com"}',
          200,
        ),
      );

      // try to make a request to an example url
      final exampleUser = await makeTrayRequest<MockUser>(
        mockRequest,
        client: mockClient,
      );

      // check for correct result type
      expect(exampleUser.data, isA<MockUser>());

      // check for correctly set properties
      expect(exampleUser.data?.id, 4);
      expect(exampleUser.data?.email, 'test4@example.com');
    });

    /// It should be possible to make post requests with a body
    test('make delete request', () async {
      // create the mock client
      final mockClient = MockClient();

      // create a mock request
      final mockRequest = DeleteMockUserRequest(
        id: 5,
      );

      // mock request response
      when(mockClient.delete(
        Uri.parse('https://api.example.com/user/5'),
        body: anyNamed('body'),
        headers: {},
      )).thenAnswer(
        (_) async => http.Response(
          '{"id": 5, "email": "test5@example.com"}',
          200,
        ),
      );

      // try to make a request to an example url
      final exampleUser = await makeTrayRequest<MockUser>(
        mockRequest,
        client: mockClient,
      );

      // check for correct result type
      expect(exampleUser.data, isA<MockUser>());

      // check for correctly set properties
      expect(exampleUser.data?.id, 5);
      expect(exampleUser.data?.email, 'test5@example.com');
    });
  });

  /// tests concerning additional properties (headers, params, ...)
  group('makeTrayRequest extra properties', () {
    /// Headers should be used correctly
    test('make post request', () async {
      // create the mock client
      final mockClient = MockClient();

      // create a mock request
      final mockRequest = FetchMockUserCustomClientRequest(
        headers: {
          'customheader1': 'customheader1_value',
        },
        params: {
          'customparam1': 'customparam1_value',
        },
      );

      // mock request response
      when(mockClient.get(
        Uri.parse(
          // baseUrl
          // ignore: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings
          'https://api.customclient.com/' +
              // url path
              'test' +
              // client params
              '?param1=param1_value' +
              // custom params
              '&customparam1=customparam1_value',
        ),
        headers: {
          'exampleheader1': 'exampleheader1_value',
          'exampleheader2': 'exampleheader2_value',
          'exampleheader3': 'exampleheader3_value',
          'customheader1': 'customheader1_value',
        },
      )).thenAnswer(
        (_) async => http.Response(
          '{"id": 3, "email": "test3@example.com"}',
          200,
        ),
      );

      // try to make a request to an example url
      final exampleUser = await makeTrayRequest<MockUser>(
        mockRequest,
        client: mockClient,
      );

      // check for correct result type
      expect(exampleUser.data, isA<MockUser>());

      // check for correctly set properties
      expect(exampleUser.data?.id, 3);
      expect(exampleUser.data?.email, 'test3@example.com');
    });
  });

  /// tests exception handling in different cases
  group('makeTrayRequest exception handling', () {
    /// Headers should be used correctly
    test('handles request exceptions with non json result', () async {
      // create the mock client
      final mockClient = MockClient();

      // create a mock request
      final mockRequest = FetchMockUserCustomClientRequest();

      // mock request response
      when(mockClient.get(
        Uri.parse(
          // baseUrl
          // ignore: prefer_adjacent_string_concatenation
          'https://api.customclient.com/test?param1=param1_value',
        ),
        headers: {
          'exampleheader1': 'exampleheader1_value',
          'exampleheader2': 'exampleheader2_value',
          'exampleheader3': 'exampleheader3_value',
        },
      )).thenAnswer(
        (_) async => http.Response(
          'NONJSONRESULT',
          500,
        ),
      );

      // try to make a request to an example url
      final exampleResult = await makeTrayRequest<MockUser>(
        mockRequest,
        client: mockClient,
        requestDebugLevel: FetchTrayDebugLevel.none,
      );

      // check for correct result type
      expect(exampleResult, isA<TrayRequestResponse<MockUser>>());

      // make sure we get an error
      expect(exampleResult.error, isA<TrayRequestError>());

      // we get the responseBody as debugInfo value
      expect(exampleResult.error?.debugInfo?['resultBody'], isNotNull);

      // make sure we get an error message
      expect(exampleResult.error?.message, isNotNull);
    });
  });
}
