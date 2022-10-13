import '../contracts/tray_request_metadata.dart';
import '../contracts/tray_request.dart';

mixin Paginatable<ResultType> {
  /// Defines the way paginated results should be combined
  ResultType mergePaginatedResults(ResultType currentData, ResultType newData);

  /// Returns the requests pagination meta information, used for controlling and showing paginated data
  dynamic generateMetaData<RequestType extends TrayRequest,
          MetadataType extends TrayRequestMetadata>(
      RequestType request, dynamic responseJson);
}
