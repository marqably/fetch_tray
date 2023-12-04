typedef TrayRequestConfigMap = Map<Type, TrayRequestConfig>;

class TrayRequestConfig {
  const TrayRequestConfig({
    required this.baseUrl,
  });

  final String baseUrl;
}
