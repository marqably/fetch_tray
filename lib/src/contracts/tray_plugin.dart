import 'package:dio/dio.dart';
import 'package:fetch_tray/fetch_tray.dart';

/// Abstract class for plugins to be used with FetchTray
///
/// The [interceptors] getter should return a list of interceptors to be used
/// with the Dio instance, which can be used to modify the request or response
/// before they are sent or returned.
///
/// The [getRequestExtra] method should return a map of extra data to be used in the request.
/// This data will be added to the [Options.extra] property and merged with other possible
/// plugins' extra data, so make sure to use unique keys.
///
/// This is useful for example to add a token to the request headers
///
/// ```dart
/// class MyPlugin extends TrayPlugin {
///   @override
///   List<Interceptor> get interceptors => [
///     InterceptorsWrapper(
///       onRequest: (options, handler) {
///         // modify options here
///         return handler.next(options);
///       },
///     ),
///   ];
/// }
/// ```
///
/// ```dart
/// class MyPlugin extends TrayPlugin {
///   @override
///   Map<String, dynamic> getRequestExtra(TrayRequest request) {
///     return {
///       'foo': 'bar',
///     };
///   }
/// }
///
/// ```
abstract class TrayPlugin {
  List<Interceptor> get interceptors;
  Map<String, dynamic> getRequestExtra(TrayRequest request);
}
