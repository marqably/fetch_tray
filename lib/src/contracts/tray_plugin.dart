import 'package:dio/dio.dart';
import 'package:fetch_tray/fetch_tray.dart';

abstract class TrayPlugin {
  List<Interceptor> get interceptors;
  Map<String, dynamic> getRequestExtra(TrayRequest request);
}
