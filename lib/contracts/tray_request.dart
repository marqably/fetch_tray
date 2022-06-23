import 'package:fetch_tray/contracts/tray_environment.dart';
import 'package:fetch_tray/contracts/tray_request_body.dart';
import 'package:fetch_tray/utils/make_tray_request.dart';

class TrayRequest<T> {
  final String url;
  T? result;
  final Map<String, String>? params;
  final TrayRequestBody? body;
  final Map<String, String>? headers;
  final MakeRequestMethod method;

  TrayRequest({
    required this.url,
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

  /// parses the params and makes sure they are either inserted into the
  /// path (if used like `/user/:var1/:var2/`) or if not defined there, they will
  /// be added as query params
  String getUrlWithParams() {
    // get the combined params of client and request
    final combinedParams = getEnvironment().getCombinedParams(params);

    // if no params given -> nothing to do
    if (combinedParams.isEmpty) {
      return getEnvironment().baseUrl + url;
    }

    // otherwise loop through the combinedParams and try to replace or add the combinedParams
    String retUrl = getEnvironment().baseUrl + url;
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
}
