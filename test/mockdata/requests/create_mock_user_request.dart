import 'package:fetch_tray/fetch_tray.dart';

import '../models/mock_user.dart';

class CreateMockUserRequestBody extends TrayRequestBody {
  final String? email;

  CreateMockUserRequestBody({
    this.email,
  });

  @override
  Future<Map<String, String>> getMap() async {
    return {
      'email': email.toString(),
    };
  }
}

class CreateMockUserRequest extends TrayRequest<MockUser> {
  CreateMockUserRequest({
    super.url = 'https://api.example.com/user',
    required CreateMockUserRequestBody super.body,
  }) : super(
          method: MakeRequestMethod.post,
        );

  @override
  MockUser getModelFromJson(dynamic json) {
    return MockUser.fromJson(json);
  }
}
