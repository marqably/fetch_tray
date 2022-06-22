enum TrayRequestBodyType {
  map,
  list,
  value,
}

/// The base type for request bodies in post/put/delete requests
///
/// It provides a `getMap()` or a `getList()` method to make sure the class is converted to a string only map.
/// This getMap or getList should be implemented individually for every request body, to make sure we don't
/// have to use dart:mirror, which introduces a few problems.
///
///
class TrayRequestBody {
  final TrayRequestBodyType bodyType = TrayRequestBodyType.map;

  /// convert the object to a list of contents
  List<dynamic> getList() {
    return [];
  }

  /// convert the object to a string only map
  Map<String, dynamic> getMap() {
    return {};
  }
}
