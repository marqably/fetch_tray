import 'dart:developer';

import 'package:fetch_tray/contracts/tray_request.dart';
import 'package:fetch_tray/utils/make_tray_request.dart';
import 'package:fetch_tray/utils/make_tray_testing_request.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import './use_make_tray_request.mocks.dart';

typedef TrayRequestFetchParser<ResultType> = ResultType Function(
    ResultType? oldData, ResultType newData);

@GenerateMocks([http.Client])
class TrayRequestHookResponse<RequestType extends TrayRequest, ResultType> {
  final Future<TrayRequestHookResponse<RequestType, ResultType>?> Function([
    RequestType? request,
    TrayRequestFetchParser<ResultType>? fetchParser,
  ]) fetch;
  final bool loading;
  final ResultType? data;
  final TrayRequestError? error;
  final RequestType request;
  final Future<void> Function()? refetch;

  TrayRequestHookResponse({
    required this.refetch,
    required this.fetch,
    required this.request,
    this.error,
    this.loading = true,
    this.data,
  });
}

/// a simple hook to make an http request
///
/// If [lazyRun] is set to true, the mutation will not run directly, but has to be triggered manually. This is useful for POST/PUT/DELETE or requests that should not happen on direct load.
TrayRequestHookResponse<RequestType, ResultType>
    useMakeTrayRequest<RequestType extends TrayRequest, ResultType>(
  RequestType request, {
  http.Client? client,
  TrayRequestMock? mock,
  bool lazyRun = false,
}) {
  final fetchResult =
      useState<TrayRequestHookResponse<RequestType, ResultType>>(
    TrayRequestHookResponse<RequestType, ResultType>(
      fetch: ([newRequest, fetchParser]) async {
        return null;
      },
      refetch: null,
      request: request,
    ),
  );

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
      mock?.result ?? '',
      mock?.statusCode ?? 200,
    ),
  );

  // define the fetch request
  Future<TrayRequestHookResponse<RequestType, ResultType>> fetchRequest([
    bool force = false,
    RequestType? customRequest,
    TrayRequestFetchParser<ResultType>? fetchParser,
  ]) async {
    // make it possible to overwrite custom request (if needed - used for example for fetch for new pages)
    final theRequest = customRequest ?? request;

    // if we are in mocking mode -> take `makeTrayTestingRequest` otherwise use `makeTrayRequest`
    final makeTrayRequestMethod = (mock != null)
        ? makeTrayTestingRequest(theRequest, mock)
        : makeTrayRequest(theRequest, client: client);

    return makeTrayRequestMethod.then((response) {
      fetchResult.value = TrayRequestHookResponse<RequestType, ResultType>(
        // if we got a custom fetch parser -> pass old and new data and take the result
        data: (fetchParser != null)
            ? fetchParser(fetchResult.value.data, response.data)
            : response.data,
        error: response.error,
        request: theRequest,
        loading: false,
        refetch: () => fetchRequest(true),
        fetch: ([
          RequestType? newCustomRequest,
          TrayRequestFetchParser<ResultType>? fetchParser,
        ]) =>
            fetchRequest(true, newCustomRequest, fetchParser),
      );

      return fetchResult.value;
    }).catchError((error, stacktrace) {
      // log error
      log(
        'An error happened with url: ${request.getUrlWithParams()}: $error',
        error: error,
        stackTrace: stacktrace,
      );

      // in case there was an uncatchable error -> handle it and turn it into our format
      fetchResult.value = TrayRequestHookResponse<RequestType, ResultType>(
        loading: false,
        request: request,
        error: TrayRequestError(
          message: error.toString(),
          errors: [],
          statusCode: 500,
        ),
        // TODO: add test for refetching
        refetch: () => fetchRequest(true),
        // TODO: add test for lazy fetching
        fetch: ([
          RequestType? newCustomRequest,
          TrayRequestFetchParser<ResultType>? fetchParser,
        ]) =>
            fetchRequest(true, newCustomRequest, fetchParser),
      );

      return fetchResult.value;
    });
  }

  // make request ist wrapped in useEffect to make sure it is only fired once
  useEffect(() {
    // if lazy run is true -> don't go any further and don't run it directly
    if (lazyRun) {
      fetchResult.value = TrayRequestHookResponse<RequestType, ResultType>(
        fetch: ([
          RequestType? newCustomRequest,
          TrayRequestFetchParser<ResultType>? fetchParser,
        ]) =>
            fetchRequest(true, newCustomRequest, fetchParser),
        refetch: null,
        request: request,
      );

      return;
    }

    // make the request and then change the state
    fetchRequest(false);
    return null;
  }, []);

  return fetchResult.value;
}
