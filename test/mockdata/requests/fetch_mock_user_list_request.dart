import 'package:fetch_tray/fetch_tray.dart';

import '../models/mock_user.dart';

class FetchMockUserListRequest extends TrayRequest<List<MockUser>> {
  FetchMockUserListRequest({
    String url = 'https://www.example.com/test',
    Map<String, String>? params,
  }) : super(
          url: url,
          params: params,
        );

  @override
  List<MockUser> getModelFromJson(dynamic json) {
    return (json as List<dynamic>)
        .map((item) => MockUser.fromJson(item))
        .toList();
  }
}
