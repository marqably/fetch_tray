import 'dart:developer';

import 'package:fetch_tray/fetch_tray.dart';
import 'package:fetch_tray_example/data/domain/api.dart';

class FetchApisRequest extends TrayRequest<List<Api>> {
  FetchApisRequest({
    Map<String, String>? params,
  }) : super(
          // Here we pass in all the configuration we need to make the reuqest
          // In this case we request a list of all the API entries from publicapis.og
          url: 'https://api.publicapis.org/entries',
          method: MakeRequestMethod.get,
          params: {
            // ...params,
            // userId: userId,
          },
          headers: {
            // 'Authorization': 'Bearer XXXXX',
          },
          body: null,
        );

  @override
  List<Api> getModelFromJson(dynamic json) {
    final List<dynamic> entries = json['entries'];
    return List.generate(
      json['entries'].length,
      (index) => Api.fromJson(json['entries'][index]),
    );
  }
}
