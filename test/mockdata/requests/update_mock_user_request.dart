import 'package:fetch_tray/contracts/tray_request.dart';
import 'package:fetch_tray/contracts/tray_request_body.dart';
import 'package:fetch_tray/utils/make_tray_request.dart';

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
    String url = 'https://api.example.com/user',
    required UpdateMockUserRequestBody body,
  }) : super(
          url: url,
          body: body,
          method: MakeRequestMethod.put,
        );

  @override
  MockUser getModelFromJson(dynamic json) {
    return MockUser.fromJson(json);
  }
}
