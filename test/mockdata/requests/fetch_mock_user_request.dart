import 'package:fetch_tray/fetch_tray.dart';
import '../models/mock_user.dart';

class FetchMockUserRequest extends TrayRequest<MockUser> {
  FetchMockUserRequest({
    super.url = 'https://www.example.com/test',
    Map<String, String>? super.params,
  });

  @override
  MockUser getModelFromJson(dynamic json) {
    return MockUser.fromJson(json);
  }
}
