import 'package:dio/dio.dart';
import 'package:fetch_tray/fetch_tray.dart';

class FetchTray {
  FetchTray._({
    this.plugins = const [],
  }) {
    dio = Dio()
      ..interceptors.addAll([
        ...plugins.map((plugin) => plugin.interceptors).expand(
              (plugin) => plugin,
            ),
      ]);
  }

  factory FetchTray.init({
    List<TrayPlugin> plugins = const [],
  }) {
    _instance = FetchTray._(
      plugins: plugins,
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
  late final List<TrayPlugin> plugins;

  static FetchTray? _instance;
}
