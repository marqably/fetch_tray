import 'package:fetch_tray/fetch_tray.dart';
import '../models/mock_user.dart';

class FetchMockUserRequest extends TrayRequest<MockUser> {
  FetchMockUserRequest({
    String url = 'https://www.example.com/test',
    Map<String, String>? params,
  }) : super(
          url: url,
          params: params,
        );

  @override
  MockUser getModelFromJson(dynamic json) {
    return MockUser.fromJson(json);
  }
}
