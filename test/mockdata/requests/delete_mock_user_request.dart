import 'package:fetch_tray/fetch_tray.dart';

import '../models/mock_user.dart';

class DeleteMockUserRequest extends TrayRequest<MockUser> {
  DeleteMockUserRequest({
    String url = 'https://api.example.com/user',
    required int id,
  }) : super(
          url: '$url/$id',
          method: MakeRequestMethod.delete,
        );

  @override
  MockUser getModelFromJson(dynamic json) {
    return MockUser.fromJson(json);
  }
}
