/// Contains meta information about a specific request, like pagination data and result information
///
/// If you want to store custom metadata, you can use `extra` to store it.
class TrayRequestMetadata {
  final int currentPage;
  final int limit;
  final int? totalPages;
  final int? totalResults;
  final bool hasNextPage;
  final bool hasPreviousPage;

  /// Can be used to store custom meta data apart from the one above
  final Map<String, String> extra;

  TrayRequestMetadata({
    required this.currentPage,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.totalResults,
    this.extra = const {},
  });
}

// MetadataType
//     defaultTrayRequestMetadata<MetadataType extends TrayRequestMetadata>() {
//   return TrayRequestMetadata(
//     currentPage: 0,
//     limit: 0,
//     totalPages: 0,
//     hasNextPage: false,
//     hasPreviousPage: false,
//     totalResults: 0,
//     extra: {},
//   );
// }
