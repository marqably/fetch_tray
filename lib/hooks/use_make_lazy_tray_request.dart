import 'dart:developer';

import 'package:fetch_tray/contracts/tray_request.dart';
import 'package:fetch_tray/utils/make_tray_request.dart';
import 'package:fetch_tray/utils/make_tray_testing_request.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
// import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import './use_make_tray_request.mocks.dart';

// @GenerateMocks([http.Client])
class LazyTrayRequestHookResponse {
  final Future<TrayRequestResponse<ResultType>> Function<ResultType>(
    TrayRequest request, {
    bool enableDebug,
  }) makeRequest;

  LazyTrayRequestHookResponse({
    required this.makeRequest,
  });
}

/// a simple hook to make an http request
///
/// If [lazyRun] is set to true, the mutation will not run directly, but has to be triggered manually. This is useful for POST/PUT/DELETE requests.
LazyTrayRequestHookResponse useMakeLazyTrayRequest({
  http.Client? client,
  TrayRequestMock? mock,
}) {
  // final fetchResult = useState<LazyTrayRequestHookResponse<ResultType>?>(
  //   LazyTrayRequestHookResponse<ResultType>(),
  // );

  // create the mock client
  final mockClient = MockClient();

  return LazyTrayRequestHookResponse(makeRequest: <ResultType>(
    TrayRequest request, {
    bool enableDebug = false,
  }) async {
    // get the correct request method
    final methodCall = getEnvironmentMethod(mockClient, request.method);

    // mock request response
    when(methodCall(
      Uri.parse(request.getUrlWithParams()),
      headers: request.getHeaders(),
      body: request.getBody(),
    )).thenAnswer(
      (_) async => http.Response(
        mock?.result ?? '',
        mock?.statusCode ?? 200,
      ),
    );

    // if we are in mocking mode -> take `makeTrayTestingRequest` otherwise use `makeTrayRequest`
    final makeTrayRequestMethod = (mock != null)
        ? makeTrayTestingRequest<ResultType>(request, mock)
        : makeTrayRequest<ResultType>(request, client: client);

    try {
      final response =
          await makeTrayRequestMethod.catchError((error, stacktrace) {
        // log error
        log(
          'An error happened with url: ${request.getUrlWithParams()}: $error',
          error: error,
          stackTrace: stacktrace,
        );

        // print out the source if something is sent along
        return TrayRequestResponse<ResultType>(
          error: TrayRequestError(
            errors: error.toString(),
            message: 'There was an unexpected error while fetching data!',
            statusCode: 500,
          ),
          data: null,
        );
      });

      // log error
      if (enableDebug) {
        log('${request.method} REQUEST: ${request.getUrlWithParams()}: ');
        inspect(request);
      }

      return response;
    } catch (err, stacktrace) {
      // log error
      log(
        'An error happened with url: ${request.getUrlWithParams()}: $err',
        error: err,
        stackTrace: stacktrace,
      );

      // print out the source if something is sent along
      debugPrint(err.toString());

      return TrayRequestResponse(
        error: TrayRequestError(
          errors: err.toString(),
          message: 'There was an unexpected error while fetching data!',
          statusCode: 500,
        ),
        data: null,
      );
    }
  });
}
