import 'package:fetch_tray/fetch_tray.dart';

import '../models/mock_user.dart';

class UpdateMockUserRequestBody extends TrayRequestBody {
  final int id;
  final String? email;

  UpdateMockUserRequestBody({
    required this.id,
    this.email,
  });

  @override
  Future<Map<String, String>> getMap() async {
    return {
      'id': id.toString(),
      'email': email.toString(),
    };
  }
}

class UpdateMockUserRequest extends TrayRequest<MockUser> {
  UpdateMockUserRequest({
    super.url = 'https://api.example.com/user',
    required UpdateMockUserRequestBody super.body,
  }) : super(
          method: MakeRequestMethod.put,
        );

  @override
  MockUser getModelFromJson(dynamic json) {
    return MockUser.fromJson(json);
  }
}
