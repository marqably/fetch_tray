import '../contracts/tray_request_metadata.dart';
import '../contracts/tray_request.dart';
import '../pagination_drivers/fetch_tray_pagination_driver.dart';

mixin Paginatable<ResultType> {
  /// A method to access the pagination provider defined for this request
  /// The provider contains normalized pagination methods like fetchMore, ...
  FetchTrayPaginationDriver<RequestType, ResultType>
      pagination<RequestType extends TrayRequest>(RequestType request) {
    return FetchTrayPaginationDriver<RequestType, ResultType>(request);
  }

  /// Defines the way paginated results should be combined
  ResultType mergePaginatedResults(ResultType currentData, ResultType newData);

  /// Returns the requests pagination meta information, used for controlling and showing paginated data
  TrayRequestMetadata generateMetaData<RequestType extends TrayRequest>(
      RequestType request, dynamic responseJson);
}
