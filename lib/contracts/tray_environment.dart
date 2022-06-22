import 'package:http/http.dart';

import '../fetch_tray.dart';

enum FetchTrayDebugLevel {
  none,
  onlyErrors,
  errorsAndWarnings,
  everything,
}

/// The client providing default data to every request being made with it
///
/// If [debugLevel] defines how much should be logged for development support purposes
class TrayEnvironment {
  final String baseUrl;
  final Map<String, String>? headers;
  final Map<String, String>? params;
  final FetchTrayDebugLevel? debugLevel;

  TrayEnvironment({
    this.baseUrl = '',
    this.headers,
    this.params,
    this.debugLevel,
  });

  /// merges custom request headers into the the headers here and
  /// returns a combined map of headers, where custom headers override default ones
  Map<String, String> getCombinedHeaders(Map<String, String>? requestHeaders) {
    final headerObj = headers ?? {};

    // if no request headers -> just return default headers
    if (requestHeaders == null || requestHeaders.isEmpty) {
      return headerObj;
    }

    // create a new map for that
    Map<String, String> retMap = {};

    // otherwise return a combination of both
    retMap.addAll(headerObj);
    retMap.addAll(requestHeaders);

    return retMap;
  }

  /// merges custom request params into the the params here and
  /// returns a combined map of params, where custom params override default ones
  Map<String, String> getCombinedParams(Map<String, String>? requestParams) {
    final paramObj = params ?? {};

    // if no request params -> just return default params
    if (requestParams == null || requestParams.isEmpty) {
      return paramObj;
    }

    // create a new map for that
    Map<String, String> retMap = {};

    // otherwise return a combination of both
    retMap.addAll(paramObj);
    retMap.addAll(requestParams);

    return retMap;
  }

  /// This method is used to parse the output of failing requests
  /// we need a way to retrieve the error message and error details
  /// if you don't use the default `message` and `errors` key, in your api, you
  /// can overwrite the mapping here and make sure everything is passed correctly
  TrayRequestError parseErrorDetails(
    TrayRequest request,
    Response response,
    Map<String, dynamic> errorBodyJson, {
    Map<String, dynamic>? debugInfo,
  }) {
    return TrayRequestError(
      message:
          errorBodyJson['message'] ?? 'Failed to load request ${request.url}!',
      errors: errorBodyJson['errors'] ?? [],
      statusCode: response.statusCode,
      debugInfo: debugInfo,
    );
  }

  /// lets us easily find out whether to show a specific log message or not
  /// it will not only match the exact log level, gut also the ones below
  /// for example, if I choose errorsAndWarning (this would also inlcude the levels above like errors or everything)
  /// TODO: write a test for this
  bool isDebugLevel(FetchTrayDebugLevel debugLevelToTest,
      [FetchTrayDebugLevel? localDebugLevel]) {
    print('THIS IS THE DEBUG LEVEL: $debugLevel');

    // if we got a local debug level -> check that
    if (localDebugLevel != null) {
      return compareDebugLevels(localDebugLevel, debugLevelToTest);
    }

    // otherwise check the global debug level
    return compareDebugLevels(debugLevel!, debugLevelToTest);
  }

  /// Compares the [currentDebugLevel] to the [comparisonDebugLevel] (the level we are checking for).
  ///
  /// It will not only match the exact log level, gut also the ones below
  /// for example, if I choose errorsAndWarning (this would also inlcude the levels above like errors or everything)
  bool compareDebugLevels(FetchTrayDebugLevel currentDebugLevel,
      FetchTrayDebugLevel comparisonDebugLevel) {
    // log level none
    if (comparisonDebugLevel == FetchTrayDebugLevel.none) {
      return false;
    }
    // log level errors
    if (comparisonDebugLevel == FetchTrayDebugLevel.onlyErrors &&
        (currentDebugLevel == FetchTrayDebugLevel.onlyErrors ||
            currentDebugLevel == FetchTrayDebugLevel.errorsAndWarnings ||
            currentDebugLevel == FetchTrayDebugLevel.everything)) {
      return true;
    }
    // log level errors and warnings
    if (comparisonDebugLevel == FetchTrayDebugLevel.errorsAndWarnings &&
        (currentDebugLevel == FetchTrayDebugLevel.errorsAndWarnings ||
            currentDebugLevel == FetchTrayDebugLevel.everything)) {
      return true;
    }
    // log level everything
    if (comparisonDebugLevel == FetchTrayDebugLevel.everything
            // TODO: check this out. This should actually not be needed, because everything is EVERYTHIng.
            &&
            currentDebugLevel == FetchTrayDebugLevel.everything
        // TODO: fix this
        ) {
      return true;
    }

    // otherwise always return false
    return false;
  }
}
