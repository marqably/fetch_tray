import 'dart:developer';

import 'package:fetch_tray/contracts/tray_environment.dart';
import 'package:fetch_tray/contracts/tray_request_body.dart';
import 'package:fetch_tray/contracts/tray_request_metadata.dart';
import 'package:fetch_tray/utils/make_tray_request.dart';

import '../pagination_drivers/fetch_tray_pagination_driver.dart';

class TrayRequest<T> {
  final String url;
  T? result;
  final Map<String, String>? params;
  final TrayRequestBody? body;
  final Map<String, String>? headers;
  final MakeRequestMethod method;
  Map<String, String> overwriteParams = {};

  TrayRequest({
    this.url = '/',
    this.params,
    this.body,
    this.method = MakeRequestMethod.get,
    this.headers,
  });

  /// returns the fetch hook client used for this request
  TrayEnvironment getEnvironment() {
    return TrayEnvironment();
  }

  /// a method, that takes a json input and returns the result method
  /// for a single entry
  dynamic getModelFromJson(/* Map<String, dynamic> */ dynamic json) {
    return;
  }

  /// a method that allows us to customize even complex url generations
  /// by default, we just return the url passed to the request here.
  String getUrl() {
    return url;
  }

  /// a method that allows us to customize even complex params generations
  /// by default, we just return the params passed to the request here.
  Map<String, String> getParamsRaw(
      [Map<String, String> customParams = const {}]) {
    return {...(params ?? {}), ...(customParams), ...overwriteParams};
  }

  /// a method that allows us to customize even complex params generations
  /// by default, we just return the params passed to the request here.
  Map<String, String>? getParams(
      [Map<String, String> requestParams = const {}]) {
    return getParamsRaw(requestParams);
  }

  /// parses the params and makes sure they are either inserted into the
  /// path (if used like `/user/:var1/:var2/`) or if not defined there, they will
  /// be added as query params
  String getUrlWithParams() {
    // get the combined params of client and request
    final clientAndRequestParams =
        getEnvironment().getCombinedParams(getParams(params ?? {}));

    // make sure that our overwrite sticks (it is possible, that the `getParams` method was overwritten,
    // but we still want to have the overwrite at the very end, but also when somebody wants to
    // return the `getParams` method. This is why we have it in there twice.)
    final combinedParams = {...clientAndRequestParams, ...overwriteParams};

    // if no params given -> nothing to do
    if (combinedParams.isEmpty) {
      return getEnvironment().baseUrl + getUrl();
    }

    // otherwise loop through the combinedParams and try to replace or add the combinedParams
    String retUrl = getEnvironment().baseUrl + getUrl();
    List<String> queryParams = [];
    for (var paramKey in combinedParams.keys) {
      // if the param key is defined within our url -> replace it there
      if (retUrl.contains(':$paramKey')) {
        retUrl = retUrl.replaceAll(':$paramKey', combinedParams[paramKey]!);
        continue;
      }

      // otherwise add it to the query combinedParams
      queryParams.add('$paramKey=${combinedParams[paramKey]!}');
    }

    // if we have query combinedParams -> add them to the url
    if (queryParams.isNotEmpty) {
      retUrl = '$retUrl?${queryParams.join('&')}';
    }

    // return it
    return retUrl;
  }

  /// returns the request body object
  getBody() {
    // if we got a map body
    if (body?.bodyType == TrayRequestBodyType.map) {
      return body?.getMap();
    }

    // if we got a map body
    if (body?.bodyType == TrayRequestBodyType.list) {
      return body?.getList();
    }

    // otherwise just return the body as is
    return body;
  }

  /// returns the combined headers from this request and client
  getHeaders() {
    return getEnvironment().getCombinedHeaders(headers);
  }

  /// this is a hook, that can be overwritten to perform actions, after the request has been done successfully
  void afterSuccess(TrayRequestResponse result) {
    // do something after saving
  }

  // #### PAGINATION

  /// A method to access the pagination provider defined for this request
  /// The provider contains normalized pagination methods like fetchMore, ...
  FetchTrayPaginationDriver<RequestType, T>
      pagination<RequestType extends TrayRequest>(RequestType request) {
    return FetchTrayPaginationDriver<RequestType, T>(request);
  }

  /// Defines the way paginated results should be combined
  /// This method should be implemented in the request itself.
  /// This is just a fallback, to throw an error if not implemented correctly.
  T mergePaginatedResults(T currentData, T newData) {
    // just return default data and throw warning
    log(
      'Please implement the mergePaginatedResults method in your request, to combine paginated results correctly.',
      name: 'fetch_tray',
    );
    return [] as T;
  }

  TrayRequestMetadata generateMetaData<RequestType extends TrayRequest>(
      RequestType request, dynamic responseJson) {
    // just return default data and throw warning
    log(
      'Please implement the mergePaginatedResults method in your request, to combine paginated results correctly.',
      name: 'fetch_tray',
    );

    return defaultTrayRequestMetadata;
  }
}
