import 'package:dio/dio.dart';
import 'package:fetch_tray/src/utils/make_tray_testing_request.mocks.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../fetch_tray.dart';

// import 'make_tray_testing_request.mocks.dart';

/// provides a mocked version of the makeTrayRequest method
/// this allows us to easily test every request, without using mockito everywhere
// @GenerateMocks([Test])
@GenerateMocks([Dio])
Future<TrayRequestResponse<ModelType>> makeTrayTestingRequest<ModelType>(
  TrayRequest request,
  TrayRequestMock mock, {
  FetchTrayDebugLevel? requestDebugLevel = FetchTrayDebugLevel.none,
}) async {
  // create the mock client
  final mockClient = MockDio();

  // await the values
  final url = Uri.parse(await request.getUrlWithParams());
  // final headers = await request.getHeaders();
  final body = await request.getBody();

  // mock request response
  when(mockClient.request(
    url.toString(),
    data: body,
    options: anyNamed('options'),
  )).thenAnswer(
    (_) async {
      return Response(
        requestOptions: RequestOptions(
          path: request.url,
        ),
        data: mock.result,
        statusCode: mock.statusCode,
        /*  headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
      }, */
      );
    },
  );

  // make request
  return makeTrayRequest(
    request,
    client: mockClient,
    requestDebugLevel: requestDebugLevel,
  );
}
