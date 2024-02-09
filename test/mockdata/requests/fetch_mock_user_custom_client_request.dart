import 'package:fetch_tray/fetch_tray.dart';
import '../models/mock_user.dart';

class FetchMockUserCustomClientRequest extends TrayRequest<MockUser> {
  /// returns the environment for this request
  @override
  TrayEnvironment getEnvironment() {
    return TrayEnvironment(
      baseUrl: 'https://api.customclient.com',
      headers: {
        'exampleheader1': 'exampleheader1_value',
        'exampleheader2': 'exampleheader2_value',
        'exampleheader3': 'exampleheader3_value',
      },
      params: {
        'param1': 'param1_value',
      },
    );
  }

  FetchMockUserCustomClientRequest({
    super.url = '/test',
    Map<String, String>? super.params,
    super.headers,
  });

  @override
  MockUser getModelFromJson(dynamic json) {
    return MockUser.fromJson(json);
  }
}
