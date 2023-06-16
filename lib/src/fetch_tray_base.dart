import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class FetchTray {
  FetchTray._({
    CacheOptions? cacheOptions,
  }) {
    final store = MemCacheStore();
    this.cacheOptions = cacheOptions ??
        CacheOptions(
          policy: CachePolicy.request,
          store: store,
        );

    dio = Dio()
      ..interceptors.addAll([
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final key = this.cacheOptions.keyBuilder(options);
            final cache = await store.get(key);

            print(cache);
          },
          onResponse: (e, handler) {
            handler.next(e);
          },
        ),
        DioCacheInterceptor(options: this.cacheOptions),
      ]);
  }

  factory FetchTray.init({
    CacheOptions? cacheOptions,
  }) {
    _instance = FetchTray._(
      cacheOptions: cacheOptions,
    );

    return _instance!;
  }

  static FetchTray get instance {
    assert(
      _instance != null,
      'You must call FetchTray.init() before using FetchTray.instance',
    );

    return _instance!;
  }

  late final Dio dio;
  late final CacheOptions cacheOptions;

  static FetchTray? _instance;
}
