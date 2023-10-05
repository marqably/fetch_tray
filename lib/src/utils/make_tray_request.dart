import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../contracts/contracts.dart';
import '../exceptions/exceptions.dart';
import '../fetch_tray_base.dart';

const validStatuses = [200, 201];

/// available request methods for makeTrayRequest requests
enum MakeRequestMethod {
  get,
  post,
  put,
  delete,
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
  final dynamic result;
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
  Dio? client,
  FetchTrayDebugLevel? requestDebugLevel,
}) async {
  final clientToUse = client ?? FetchTray.instance.dio;
  Response response = Response(
    requestOptions: RequestOptions(
      path: request.url,
    ),
  );

  try {
    final pluginRequestExtra = FetchTray.instance.plugins.map(
      (plugin) => plugin.getRequestExtra(request),
    );
    Map<String, dynamic> mergedRequestExtra = {};

    if (pluginRequestExtra.isNotEmpty) {
      mergedRequestExtra =
          pluginRequestExtra.reduce((value, element) => value..addAll(element));
    }

    final options = Options(
      method: request.method.toString().split('.').last,
      headers: await request.getHeaders(),
      extra: mergedRequestExtra,
    );

    // if in debug mode (at least FetchTrayDebugLevel.everything) -> log
    logRequest(
      message:
          '---------------------------------- \nStarting FetchTray Request (${request.getUrlWithParams()})',
      logType: FetchTrayLogLevel.info,
      requestDebugLevel: requestDebugLevel,
      request: request,
    );

    response = await clientToUse.request(
      await request.getUrlWithParams(),
      data: await request.getBody(),
      options: options,
    );

    // if in debug mode (at least FetchTrayDebugLevel.everything) -> log
    logRequest(
      message: 'FetchTray Response (${request.getUrlWithParams()})',
      logType: FetchTrayLogLevel.info,
      requestDebugLevel: requestDebugLevel,
      request: request,
      response: response,
    );

    try {
      final trayRequestResponse = TrayRequestResponse<ModelType>(
        data: request.getModelFromJson(
          response.data,
        ),
        dataRaw: response.data,
      );

      // call after success hook
      request.afterSuccess(trayRequestResponse);

      // return it
      return Future.value(trayRequestResponse);
    } catch (e, st) {
      throw JsonConversionException(e.toString(), st);
    }
  } on DioException catch (e) {
    // log error
    logRequest(
      message:
          'FETCH TRAY EXCEPTION: Api returned the status error code ${e.response?.statusCode ?? 500}',
      logType: FetchTrayLogLevel.error,
      requestDebugLevel: requestDebugLevel,
      request: request,
      response: e.response,
    );

    if (e.response != null) {
      return TrayRequestResponse(
        error: request.getEnvironment().parseErrorDetails(
              request,
              e.response!,
              e.response!.data,
            ),
      );
    } else {
      logRequest(
        message:
            'FETCH TRAY EXCEPTION: Something happened in setting up or sending the request that triggered an error.',
        logType: FetchTrayLogLevel.error,
        requestDebugLevel: requestDebugLevel,
        request: request,
        response: e.response,
      );

      return TrayRequestResponse<ModelType>(
        error: TrayRequestError(
          message: e.message ?? 'Unexpected error',
          errors: null,
          statusCode: 500,
        ),
      );
    }
  } on JsonConversionException catch (err) {
    logRequest(
      message:
          'FETCH TRAY EXCEPTION: Could not convert the code to json! ${err.toString()}',
      logType: FetchTrayLogLevel.error,
      requestDebugLevel: requestDebugLevel,
      request: request,
    );

    return TrayRequestResponse<ModelType>(
      error: request.getEnvironment().parseErrorDetails(
        request,
        response,
        {
          'message': err.message,
        },
        debugInfo: {
          'stackTrace': err.stackTrace,
          'debugHint':
              'FetchTray result could not be converted! Please check whether the result was really a json entity representing the model. (${err.toString()})',
          'resultBody': response.data,
        },
      ),
    );
  } catch (err, stackTrace) {
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
    return TrayRequestResponse<ModelType>(
      error: request.getEnvironment().parseErrorDetails(
        request,
        response,
        {},
        debugInfo: {
          'resultBody': response.data,
        },
      ),
    );
  }
}

/// provides a shortcut to logging out requests
void logRequest({
  required TrayRequest request,
  required FetchTrayLogLevel logType,
  // http.Response? response,
  Response? response,
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
      'resultBody': response?.data,
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
