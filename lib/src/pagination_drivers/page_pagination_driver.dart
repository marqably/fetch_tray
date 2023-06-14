import '../contracts/tray_request.dart';
import 'fetch_tray_pagination_driver.dart';

class PagePaginationDriver<RequestType extends TrayRequest, ResultType>
    extends FetchTrayPaginationDriver<RequestType, ResultType> {
  PagePaginationDriver(
    RequestType request, {
    this.firstPage = 1,
    this.pageProperty = 'page',
  }) : super(request);

  /// Defines whether the first page starts with 0 or 1 (depending on the api, this can differ)
  final int firstPage;

  /// Defines the property key used to pass the page to the request url
  /// This is used for pagination to increase the page inside of the `fetchMore` method.
  final String pageProperty;

  /// Defines the property key used to pass the page to the request url
  /// This is used for pagination to increase the page inside of the `fetchMore` method.
  String paginationProperty() {
    return 'page';
  }

  /// This method defines the way we determine whether our current request has more data to fetch.
  @override
  Future<RequestType> fetchMoreRequest() async {
    // get current params
    final currentParams = await request.getParams();

    // get the next page
    final nextPage =
        int.parse(currentParams[paginationProperty()] ?? firstPage.toString()) +
            1;

    request.overwriteParams = {
      paginationProperty(): nextPage.toString(),
    };

    return request;
  }
}
