import 'package:http/http.dart';

import '../fetch_tray.dart';

enum FetchTrayDebugLevel {
  none,
  onlyErrors,
  errorsAndWarnings,
  everything,
}

enum FetchTrayLogLevel {
  info,
  warning,
  error,
}

/// The client providing default data to every request being made with it
///
/// If [debugLevel] defines how much should be logged for development support purposes
class TrayEnvironment {
  final String baseUrl;
  final Map<String, String>? headers;
  final Map<String, String>? params;
  final FetchTrayDebugLevel debugLevel;

  TrayEnvironment({
    this.baseUrl = '',
    this.headers,
    this.params,
    this.debugLevel = FetchTrayDebugLevel.errorsAndWarnings,
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

  /// lets us easily find out whether to show a specific [logType] message or not
  ///
  /// If a [localDebugLevel] is provided, our logType will be compared against that
  /// If no [localDebugLevel] is provided, we will use the global one defined by TrayEnvironment initialization.
  bool showDebugInfo({
    FetchTrayLogLevel logType = FetchTrayLogLevel.info,
    FetchTrayDebugLevel? localDebugLevel,
  }) {
    // if we got a local debug level -> check that
    if (localDebugLevel != null) {
      return matchesDebugLevels(
        logType: logType,
        requestDebugLevel: localDebugLevel,
      );
    }

    // otherwise check the global debug level
    return matchesDebugLevels(
      logType: logType,
      requestDebugLevel: debugLevel,
    );
  }

  /// Compares the [logType] to the [requestDebugLevel] to find out whether a debug Info should be shown for this combination or not.
  ///
  /// The result will be a boolean telling us whether we should log something.
  bool matchesDebugLevels({
    FetchTrayLogLevel logType = FetchTrayLogLevel.info,
    FetchTrayDebugLevel requestDebugLevel = FetchTrayDebugLevel.everything,
  }) {
    // log level none
    if (requestDebugLevel == FetchTrayDebugLevel.none) {
      return false;
    }

    // log level errors
    if (requestDebugLevel == FetchTrayDebugLevel.onlyErrors &&
        logType == FetchTrayLogLevel.error) {
      return true;
    }

    // log level errors and warnings
    if (requestDebugLevel == FetchTrayDebugLevel.errorsAndWarnings &&
        (logType == FetchTrayLogLevel.warning ||
            logType == FetchTrayLogLevel.error)) {
      return true;
    }

    // log level everything
    if (requestDebugLevel == FetchTrayDebugLevel.everything) {
      return true;
    }

    // otherwise always return false
    return false;
  }
}
