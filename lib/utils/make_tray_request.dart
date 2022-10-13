import 'dart:convert';
import 'package:fetch_tray/contracts/tray_request.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../contracts/tray_environment.dart';

const validStatuses = [200, 201];

/// available request methods for makeTrayRequest requests
enum MakeRequestMethod {
  get,
  post,
  put,
  delete,
}

/// Maps our MakeRequestMethod enum to the corresponding client method
Future<dynamic> Function(
  Uri url, {
  Map<String, String>? headers,
  dynamic body,
}) getEnvironmentMethod(http.Client client, MakeRequestMethod method) {
  switch (method) {
    case MakeRequestMethod.get:
      // normalize this method to make sure the addition of `body` does not
      // end up producing type issues
      return (
        Uri url, {
        Map<String, String>? headers,
        dynamic body,
      }) {
        return client.get(url, headers: headers);
      };
    case MakeRequestMethod.put:
      return (
        Uri url, {
        Map<String, String>? headers,
        dynamic body,
      }) {
        return client.put(url, headers: headers, body: jsonEncode(body));
      };
    case MakeRequestMethod.delete:
      return (
        Uri url, {
        Map<String, String>? headers,
        dynamic body,
      }) {
        return client.delete(url, headers: headers, body: jsonEncode(body));
      };
    case MakeRequestMethod.post:
      return (
        Uri url, {
        Map<String, String>? headers,
        dynamic body,
      }) {
        final bodyResult = jsonEncode(body);
        return client.post(url, headers: headers, body: bodyResult);
      };
    default:
      throw Exception('Request method $method is not defined');
  }
}

/// An error object, containing details of errors happening in a request
class TrayRequestError {
  final String message;
  final dynamic errors;
  final int statusCode;
  final Map<String, dynamic>? debugInfo;

  TrayRequestError({
    required this.message,
    required this.errors,
    required this.statusCode,
    this.debugInfo,
  });
}

/// the response class of a tray request, containing either the data or an error object
class TrayRequestResponse<ResultType> {
  final ResultType? data;
  final dynamic dataRaw;
  final TrayRequestError? error;

  TrayRequestResponse({
    this.error,
    this.dataRaw,
    this.data,
  });
}

/// an object containing mock details
class TrayRequestMock {
  final String result;
  final int statusCode;

  TrayRequestMock(
    this.result, {
    this.statusCode = 200,
  });
}

/// makes the process of requesting data from an api endpoint easier
/// it takes care of making the request and mocking
Future<TrayRequestResponse<ModelType>> makeTrayRequest<ModelType>(
  TrayRequest request, {
  http.Client? client,
  FetchTrayDebugLevel? requestDebugLevel,
}) async {
  // define the client
  final theClient = client ?? http.Client();

  // get the correct caller method
  final methodCaller = getEnvironmentMethod(theClient, request.method);

  // the response
  var response = http.Response('', 200);

  try {
    // if in debug mode (at least FetchTrayDebugLevel.everything) -> log
    logRequest(
      message:
          '---------------------------------- \nStarting FetchTray Request (${request.getUrlWithParams()})',
      logType: FetchTrayLogLevel.info,
      requestDebugLevel: requestDebugLevel,
      request: request,
      response: response,
    );

    final url = Uri.parse(await request.getUrlWithParams());
    final headers = await request.getHeaders();
    final body = await request.getBody();

    // make request
    response = await methodCaller(
      url,
      headers: headers,
      body: body,
    );

    // if in debug mode (at least FetchTrayDebugLevel.everything) -> log
    logRequest(
      message: 'FetchTray Response (${request.getUrlWithParams()})',
      logType: FetchTrayLogLevel.info,
      requestDebugLevel: requestDebugLevel,
      request: request,
      response: response,
    );

    // if response successful -> parse it and return
    if (validStatuses.contains(response.statusCode)) {
      final responseJson =
          (response.body != '') ? jsonDecode(response.body) : response.body;

      try {
        final trayRequestResponse = TrayRequestResponse<ModelType>(
          data: request.getModelFromJson(
            responseJson,
          ),
          dataRaw: responseJson,
        );

        // call after success hook
        request.afterSuccess(trayRequestResponse);

        // return it
        return Future.value(trayRequestResponse);
      } catch (err) {
        // log error
        logRequest(
          message:
              'FETCH TRAY EXCEPTION: Could not convert the code to json! ${err.toString()}',
          logType: FetchTrayLogLevel.error,
          requestDebugLevel: requestDebugLevel,
          request: request,
          response: response,
        );

        final trayRequestResponse = TrayRequestResponse<ModelType>(
          error: request.getEnvironment().parseErrorDetails(
            request,
            response,
            {'rawJson': response.body},
          ),
        );
        return Future.value(trayRequestResponse);
      }
    }

    // try to parse the json anyway, so we can get a good error message
    final bodyJson = jsonDecode(response.body);

    // log error
    logRequest(
      message:
          'FETCH TRAY EXCEPTION: Api returned the status error code ${response.statusCode}',
      logType: FetchTrayLogLevel.error,
      requestDebugLevel: requestDebugLevel,
      request: request,
      response: response,
    );

    // If the server did not return a 200 OK response,
    // then throw an exception.
    return TrayRequestResponse(
      error: request.getEnvironment().parseErrorDetails(
            request,
            response,
            bodyJson,
          ),
    );
  }
  // If we got an error related to formatting -> we probably got a wrong response from server
  // either no json response, or the json doesn't match our model
  on FormatException catch (err, stackTrace) {
    // if in debug mode (at least FetchTrayDebugLevel.onlyErrors) -> allow logging
    logRequest(
      message:
          'FETCH TRAY FORMAT EXCEPTION: result could not be converted! Please check whether the result was really a json entity representing the model. (${err.toString()})',
      logType: FetchTrayLogLevel.error,
      requestDebugLevel: requestDebugLevel,
      request: request,
      response: response,
      stackTrace: stackTrace,
    );

    // return tray response with error
    return TrayRequestResponse(
      error: request.getEnvironment().parseErrorDetails(
        request,
        response,
        {
          'message': 'Unexpected server response!',
        },
        debugInfo: {
          'debugHint':
              'FetchTray result could not be converted! Please check whether the result was really a json entity representing the model. (${err.toString()})',
          'resultBody': response.body,
        },
      ),
    );
  } on Exception catch (err, stackTrace) {
    // log an error to console
    logRequest(
      message: 'FETCH TRAY EXCEPTION: ${err.toString()}',
      logType: FetchTrayLogLevel.error,
      requestDebugLevel: requestDebugLevel,
      request: request,
      response: response,
      stackTrace: stackTrace,
    );

    // If there was another exception
    // then throw an exception.
    return TrayRequestResponse(
      error: request.getEnvironment().parseErrorDetails(
        request,
        response,
        {},
        debugInfo: {
          'resultBody': response.body,
        },
      ),
    );
  }
}

/// provides a shortcut to logging out requests
void logRequest({
  required TrayRequest request,
  required FetchTrayLogLevel logType,
  required http.Response response,
  FetchTrayDebugLevel? requestDebugLevel,
  String? message,
  StackTrace? stackTrace,
}) async {
  final shouldBeShown = (request
      .getEnvironment()
      .showDebugInfo(logType: logType, localDebugLevel: requestDebugLevel));

  // if should not be shown -> do nothing
  if (shouldBeShown == false) {
    return;
  }

  var logger = Logger();

  // await values
  final url = Uri.parse(await request.getUrlWithParams());
  final headers = await request.getHeaders();
  final body = await request.getBody();

  // define request details:
  var encoder = const JsonEncoder.withIndent("     ");
  final requestDetails = encoder.convert(
    {
      'requestUrl': request.url,
      'method': request.method.toString(),
      'request': url.toString(),
      'headers': headers,
      'body': body,
      'resultBody': response.body,
    },
  );

  // if we have an error -> show error logging
  switch (logType) {
    case FetchTrayLogLevel.info:
      logger.i('${message ?? 'FetchTray Info'}\n\n$requestDetails');
      break;
    case FetchTrayLogLevel.warning:
      logger.w(requestDetails, message ?? 'FetchTray Warning', stackTrace);
      break;
    case FetchTrayLogLevel.error:
      logger.e(requestDetails, message ?? 'FetchTray Error', stackTrace);
      break;
  }
}
