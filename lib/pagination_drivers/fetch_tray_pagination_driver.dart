import '../contracts/tray_request.dart';
import '../utils/make_tray_request.dart';

class FetchTrayPaginationDriver<RequestType extends TrayRequest, ResultType> {
  FetchTrayPaginationDriver(this.request);

  /// keeps the current request for use in [fetchMore] method
  final RequestType request;

  /// Defines the property key used to pass the page to the request url
  /// This is used for pagination to increase the page inside of the `fetchMore` method.
  String paginationProperty() {
    return 'page';
  }

  /// This method defines the way we determine whether our current request has more data to fetch.
  RequestType fetchMoreRequest() {
    // get current params
    final currentParmas = request.getParams();

    // get the next page
    final nextPage = int.parse(currentParmas?[paginationProperty()] ?? '0') + 1;

    request.overwriteParams = {
      paginationProperty(): nextPage.toString(),
    };

    return request;
  }

  /// This method defines the way we determine whether our current request has more data to fetch.
  bool hasMorePages(TrayRequestResponse result) {
    return false;
  }
}
