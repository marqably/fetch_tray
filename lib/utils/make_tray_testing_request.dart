import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../fetch_tray.dart';
import 'make_tray_testing_request.mocks.dart';

/// provides a mocked version of the makeTrayRequest method
/// this allows us to easily test every request, without using mockito everywhere
@GenerateMocks([http.Client])
Future<TrayRequestResponse<ModelType>> makeTrayTestingRequest<ModelType>(
  TrayRequest request,
  TrayRequestMock mock, {
  FetchTrayDebugLevel? requestDebugLevel = FetchTrayDebugLevel.none,
}) async {
  // create the mock client
  final mockClient = MockClient();

  // get the correct request method
  final methodCall = getEnvironmentMethod(mockClient, request.method);

  // mock request response
  when(methodCall(
    Uri.parse(request.getUrlWithParams()),
    headers: request.getHeaders(),
    body: request.getBody(),
  )).thenAnswer(
    (_) async => http.Response(
      mock.result,
      mock.statusCode,
    ),
  );

  // make request
  return makeTrayRequest(
    request,
    client: mockClient,
    requestDebugLevel: requestDebugLevel,
  );
}
