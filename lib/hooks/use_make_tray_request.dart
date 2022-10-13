import 'dart:developer';

import 'package:fetch_tray/contracts/tray_request_metadata.dart';
import 'package:fetch_tray/contracts/tray_environment.dart';
import 'package:fetch_tray/contracts/tray_request.dart';
import 'package:fetch_tray/utils/make_tray_request.dart';
import 'package:fetch_tray/utils/make_tray_testing_request.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import './use_make_tray_request.mocks.dart';

typedef FetchMoreMethodType<RequestType extends TrayRequest, ResultType,
        MetadataType extends TrayRequestMetadata>
    = Future<
            TrayRequestHookResponse<RequestType, ResultType,
                TrayRequestMetadata>?>
        Function();

typedef UseMakeRequestFetchMethod<RequestType extends TrayRequest, ResultType,
        MetadataType extends TrayRequestMetadata>
    = Future<
            TrayRequestHookResponse<RequestType, ResultType,
                TrayRequestMetadata>?>
        Function([
  RequestType? request,
  TrayRequestFetchParser<ResultType>? fetchParser,
]);

typedef TrayRequestFetchParser<ResultType> = ResultType Function(
    ResultType? oldData, ResultType newData);

@GenerateMocks([http.Client])
class TrayRequestHookResponse<RequestType extends TrayRequest, ResultType,
    MetadataType extends TrayRequestMetadata> {
  final UseMakeRequestFetchMethod<RequestType, ResultType, TrayRequestMetadata>
      fetch;
  final bool fetchMoreLoading;
  final bool loading;
  final MetadataType? metadata;
  final ResultType? data;
  final TrayRequestError? error;
  final RequestType request;
  final Future<void> Function(Map<String, String?> overwriteParams) refetch;
  final FetchMoreMethodType<RequestType, ResultType, TrayRequestMetadata>
      fetchMore;

  TrayRequestHookResponse({
    required this.refetch,
    required this.fetchMore,
    required this.fetch,
    required this.request,
    required this.metadata,
    this.error,
    this.loading = true,
    this.fetchMoreLoading = false,
    this.data,
  });

  TrayRequestHookResponse<RequestType, ResultType, MetadataType> copyWith({
    bool? loading,
    bool? fetchMoreLoading,
    MetadataType? metadata,
    ResultType? data,
    TrayRequestError? error,
    RequestType? request,
    UseMakeRequestFetchMethod<RequestType, ResultType, MetadataType>? fetch,
    Future<void> Function(Map<String, String?> overwriteParams)? refetch,
    FetchMoreMethodType<RequestType, ResultType, MetadataType>? fetchMore,
  }) {
    return TrayRequestHookResponse(
      refetch: refetch ?? this.refetch,
      fetchMore: fetchMore ?? this.fetchMore,
      fetch: fetch ?? this.fetch,
      request: request ?? this.request,
      metadata: metadata ?? this.metadata,
      error: error ?? this.error,
      loading: loading ?? this.loading,
      fetchMoreLoading: fetchMoreLoading ?? this.fetchMoreLoading,
      data: data ?? this.data,
    );
  }
}

createHookResponse<RequestType extends TrayRequest, ResultType,
    MetadataType extends TrayRequestMetadata>({
  required RequestType request,
  required UseMakeRequestFetchMethod<RequestType, ResultType, MetadataType>
      fetch,
  required Future<void> Function(Map<String, String?> overwriteParams) refetch,
  required FetchMoreMethodType<RequestType, ResultType, MetadataType> fetchMore,
  MetadataType? metadata,
  bool loading = true,
  bool fetchMoreLoading = false,
  ResultType? data,
  TrayRequestError? error,
}) {
  return TrayRequestHookResponse<RequestType, ResultType, MetadataType>(
    refetch: refetch,
    fetchMore: fetchMore,
    fetch: fetch,
    request: request,
    metadata: metadata,
    error: error,
    loading: loading,
    fetchMoreLoading: fetchMoreLoading,
    data: data,
  );
}

/// a simple hook to make an http request
///
/// If [lazyRun] is set to true, the mutation will not run directly, but has to be triggered manually. This is useful for POST/PUT/DELETE or requests that should not happen on direct load.
TrayRequestHookResponse<RequestType, ResultType, MetadataType>
    useMakeTrayRequest<RequestType extends TrayRequest, ResultType,
        MetadataType extends TrayRequestMetadata>(
  RequestType initialRequest, {
  http.Client? client,
  TrayRequestMock? mock,
  bool lazyRun = false,
  FetchTrayDebugLevel? requestDebugLevel = FetchTrayDebugLevel.none,
}) {
  final requestState = useState<RequestType>(initialRequest);
  final request = requestState.value;

  final fetchResult =
      useState<TrayRequestHookResponse<RequestType, ResultType, MetadataType>>(
    createHookResponse<RequestType, ResultType, MetadataType>(
      fetch: ([newRequest, fetchParser]) async {
        return null;
      },
      metadata: null, // defaultTrayRequestMetadata(),
      refetch: (overwriteParams) async {},
      request: request,
      fetchMore: () async {
        return null;
      },
    ),
  );

  // create the mock client
  final mockClient = MockClient();

  // get the correct request method
  final methodCall = getEnvironmentMethod(mockClient, request.method);

  // mock request response
  Future<void> mockData() async {
    final url = Uri.parse(await request.getUrlWithParams());
    final headers = await request.getHeaders();
    final body = await request.getBody();

    when(methodCall(
      url,
      headers: headers,
      body: body,
    )).thenAnswer(
      (_) async => http.Response(
        mock?.result ?? '',
        mock?.statusCode ?? 200,
      ),
    );
  }

  // define the fetch request
  Future<TrayRequestHookResponse<RequestType, ResultType, TrayRequestMetadata>>
      fetchRequest([
    bool force = false,
    RequestType? customRequest,
    TrayRequestFetchParser<ResultType>? fetchParser,
    bool isFetchMore = false,
  ]) async {
    // mock the request data if we are in mock mode
    // if (mock != null) await mockData();
    await mockData();

    // make it possible to overwrite custom request (if needed - used for example for fetch for new pages)
    final theRequest = customRequest ?? request;

    // if we are in mocking mode -> take `makeTrayTestingRequest` otherwise use `makeTrayRequest`
    final makeTrayRequestMethod = (mock != null)
        ? makeTrayTestingRequest(
            theRequest,
            mock,
            requestDebugLevel: requestDebugLevel,
          )
        : makeTrayRequest(
            theRequest,
            client: client,
            requestDebugLevel: requestDebugLevel,
          );

    // define our fetch again method
    Future<
        TrayRequestHookResponse<RequestType, ResultType,
            TrayRequestMetadata>> fetchAgainMethod([
      RequestType? newCustomRequest,
      TrayRequestFetchParser<ResultType>? fetchParser,
    ]) async {
      if (newCustomRequest != null) {
        requestState.value = newCustomRequest;
      }

      if (fetchResult.value.loading != true) {
        fetchResult.value = fetchResult.value.copyWith(loading: true);
      }

      // fetch the request
      return fetchRequest(
        true,
        newCustomRequest,
        fetchParser,
      );
    }

    // define our refetch method
    Future<
        TrayRequestHookResponse<RequestType, ResultType,
            TrayRequestMetadata>> refetchMethod(
        Map<String, String?> overwriteParams) {
      fetchResult.value = fetchResult.value.copyWith(loading: true);

      // overwrite the params
      request.overwriteParams = {
        ...request.overwriteParams,
        ...overwriteParams,
      };

      return fetchRequest(
        true,
        request,
        fetchParser,
      );
    }

    return makeTrayRequestMethod.then((response) async {
      // if we got a custom fetch parser -> pass old and new data and take the result
      final newDataDefined = (fetchParser != null)
          ? fetchParser(fetchResult.value.data, response.data)
          : response.data;

      // depending on whether this is a reset or a fetch more -> use the old data or try to combine data
      final newData = (isFetchMore)
          ? request.mergePaginatedResults(
              fetchResult.value.data,
              newDataDefined,
            )
          : newDataDefined;

      // get the pagination metadata
      final metadata =
          await theRequest.generateMetaData<RequestType, MetadataType>(
              request, response.dataRaw ?? {});

      // set the new state
      final newResponse =
          TrayRequestHookResponse<RequestType, ResultType, MetadataType>(
        data: newData,
        error: response.error,
        request: theRequest,
        loading: false,
        fetchMoreLoading: false,
        metadata: metadata,
        refetch: refetchMethod,
        // TODO: add test for fetchMore
        fetchMore: () async {
          // set the loading state
          fetchResult.value = fetchResult.value.copyWith(
            fetchMoreLoading: true,
          );

          final fetchMoreRequest = await requestState.value
              .pagination<RequestType>(requestState.value)
              .fetchMoreRequest();

          // make the request
          return fetchRequest(
            true,
            fetchMoreRequest,
            fetchParser,
            true,
          );
        },
        fetch: fetchAgainMethod,
      );

      try {
        fetchResult.value = newResponse;

        return fetchResult.value;
      } catch (e) {
        // if the fetchResult state does not exist anymore (hook was unmounted) -> just return without setting the state
        // we have to find a cleaner solution for this, but for now it works and does not produce errors.
        // need to check for possible memory leaks though
        return newResponse;
      }
    }).catchError((error, stacktrace) async {
      // log error
      log(
        'An error happened with url: ${await request.getUrlWithParams()}: $error',
        error: error,
        stackTrace: stacktrace,
      );

      // in case there was an uncatchable error -> handle it and turn it into our format
      fetchResult.value =
          createHookResponse<RequestType, ResultType, MetadataType>(
        loading: false,
        fetchMoreLoading: false,
        request: request,
        error: TrayRequestError(
          message: error.toString(),
          errors: [],
          statusCode: 500,
        ),
        metadata: null, // defaultTrayRequestMetadata(),
        fetchMore: () async {
          return null;
        },
        // TODO: add test for refetching
        refetch: refetchMethod,
        // TODO: add test for lazy fetching
        fetch: fetchAgainMethod,
      );

      return fetchResult.value;
    });
  }

  // make request ist wrapped in useEffect to make sure it is only fired once
  useEffect(() {
    // if lazy run is true -> don't go any further and don't run it directly
    if (lazyRun) {
      fetchResult.value =
          createHookResponse<RequestType, ResultType, MetadataType>(
        fetch: ([
          RequestType? newCustomRequest,
          TrayRequestFetchParser<ResultType>? fetchParser,
        ]) =>
            fetchRequest(true, newCustomRequest, fetchParser),
        refetch: (overwriteParams) async {},
        fetchMore: () async {
          return null;
        },
        metadata: null, //defaultTrayRequestMetadata(),
        request: request,
      );

      return () {
        fetchResult.removeListener(() {});
      };
    }

    // make the request and then change the state
    fetchRequest(false);

    return () {
      fetchResult.removeListener(() {});
    };
  }, []);

  return fetchResult.value;
}
