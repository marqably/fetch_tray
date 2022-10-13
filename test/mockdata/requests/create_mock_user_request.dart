import 'package:fetch_tray/contracts/tray_request.dart';
import 'package:fetch_tray/contracts/tray_request_body.dart';
import 'package:fetch_tray/utils/make_tray_request.dart';

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
    String url = 'https://api.example.com/user',
    required CreateMockUserRequestBody body,
  }) : super(
          url: url,
          body: body,
          method: MakeRequestMethod.post,
        );

  @override
  MockUser getModelFromJson(dynamic json) {
    return MockUser.fromJson(json);
  }
}
