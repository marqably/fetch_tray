import 'dart:developer';

import '../contracts/tray_request.dart';

class FetchTrayPaginationDriver<RequestType extends TrayRequest, ResultType> {
  FetchTrayPaginationDriver(this.request);

  /// keeps the current request for use in [fetchMore] method
  final RequestType request;

  /// This method defines the way we determine whether our current request has more data to fetch.
  Future<RequestType> fetchMoreRequest() async {
    log('Please implement the fetchMoreRequest method in $RequestType');
    return request;
  }
}
