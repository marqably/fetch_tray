/* import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart'; */
import 'package:fetch_tray/fetch_tray.dart';
// import 'package:fetch_tray_cache_plugin/fetch_tray_cache.dart';

class MyRequest<T> extends TrayRequest<T> {
  MyRequest({
    required super.url,
    super.params,
    super.body,
    super.method = MakeRequestMethod.get,
    super.headers,
  });

  @override
  TrayEnvironment getEnvironment() {
    return TrayEnvironment(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      headers: {
        'content-type': 'application/json',
      },
      params: {},
      debugLevel: FetchTrayDebugLevel.everything,
    );
  }

  Future<TrayRequestResponse<T>> send() async {
    return makeTrayRequest<T>(this);
  }
}

class TestCachedRequest extends MyRequest<String> {
  TestCachedRequest()
      : super(
          url: 'https://hub.dummyapis.com/delay?seconds=1',
        );

  @override
  getModelFromJson(json) {
    return json;
  }
}

class TestLongCachedRequest extends MyRequest<String> {
  TestLongCachedRequest()
      : super(
          url: 'https://hub.dummyapis.com/delay?seconds=1',
        );

  @override
  getModelFromJson(json) {
    return json;
  }
}

/* Future<void> sequentialRequests(bool cache) async {
  final stopwatch = Stopwatch();
  final request = DelayedRequest(cache: cache);
  stopwatch.start();
  var i = 0;
  var lastTimestamp = 0;
  print('Running benchmark ${cache ? "with" : "without"} cache');
  while (i < 10) {
    final result = await request.send();
    print(result.data);
    print(
        'Request ${i + 1} took ${stopwatch.elapsedMilliseconds - lastTimestamp}ms');
    lastTimestamp = stopwatch.elapsedMilliseconds;
    i++;
  }
  stopwatch.stop();
  print('Sequential requests took ${stopwatch.elapsedMilliseconds}ms');
} */

void main() async {
  FetchTray.init(
    plugins: [],
  );

  final normalCachedRequest = TestCachedRequest();
  final longCachedRequest = TestLongCachedRequest();

  await normalCachedRequest.send();
  await longCachedRequest.send();
}
