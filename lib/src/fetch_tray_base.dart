import 'package:dio/dio.dart';
import 'package:fetch_tray/fetch_tray.dart';

/// The base class for fetch_tray.
///
/// It is a singleton class, so you can access it anywhere in your app by calling
/// `FetchTray.instance`. It is initialized by calling `FetchTray.init()`, which
/// must be called before using the instance. It can be initialized with a list
/// of plugins, a Dio instance and a map of request configs.
class FetchTray {
  FetchTray._({
    this.plugins = const [],
    Dio? dio,
    this.requestConfigs = const {},
  }) {
    final dioClient = dio ?? Dio();
    this.dio = dioClient
      ..interceptors.addAll([
        ...plugins.map((plugin) => plugin.interceptors).expand(
              (plugin) => plugin,
            ),
      ]);
  }

  /// Initializes FetchTray with the given [plugins], [dio] instance and
  /// [requestConfigs].
  factory FetchTray.init({
    List<TrayPlugin> plugins = const [],
    Dio? dio,
    TrayRequestConfigMap? requestConfigs,
  }) {
    _instance = FetchTray._(
      plugins: plugins,
      dio: dio,
      requestConfigs: requestConfigs ?? {},
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

  /// The Dio instance used by FetchTray
  late final Dio dio;

  /// A list of plugins to be used with FetchTray
  late final List<TrayPlugin> plugins;

  /// A map of request configs, where the key is the request type and the value
  /// is the request config.
  late final TrayRequestConfigMap requestConfigs;

  static FetchTray? _instance;

  /// Returns the request config for the given request type. This is useful
  /// for example to get the base url for a request. If no request config is
  /// found for the given request type, an exception is thrown.
  TrayRequestConfig getRequestConfig(Type request) {
    assert(
      requestConfigs.keys.isNotEmpty,
      'You must provide at least one request config to FetchTray.init to use getRequestConfig',
    );

    if (requestConfigs.keys.contains(request)) {
      return requestConfigs[request]!;
    } else {
      throw Exception('No request config found for $request');
    }
  }
}
