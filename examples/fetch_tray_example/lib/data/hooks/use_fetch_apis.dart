import 'package:fetch_tray/fetch_tray.dart';
import 'package:fetch_tray_example/data/domain/api.dart';
import 'package:fetch_tray_example/data/requests/fetch_apis_request.dart';

typedef FetchApisHookReturnType
    = TrayRequestHookResponse<FetchApisRequest, List<Api>, TrayRequestMetadata>;

FetchApisHookReturnType useFetchApis(
    {FetchTrayDebugLevel? requestDebugLevel = FetchTrayDebugLevel.none
    // Here we pass in all the configuration we need to make the reuqest
    }) {
  return useMakeTrayRequest<FetchApisRequest, List<Api>, TrayRequestMetadata>(
    FetchApisRequest(),
    requestDebugLevel: requestDebugLevel,
  );
}
