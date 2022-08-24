
// class PagePaginationDriver<RequestType extends TrayRequest, ResultType>
//     extends FetchTrayPaginationDriver<RequestType, ResultType> {
//   PagePaginationDriver(request) : super(request);

//   /// Defines whether the first page starts with 0 or 1 (depending on the api, this can differ)
//   static const firstPage = 1;

//   /// Defines the property key used to pass the page to the request url
//   /// This is used for pagination to increase the page inside of the `fetchMore` method.
//   static const pageProperty = 'page';

//   /// This method defines the way we determine whether our current request has more data to fetch.
//   @override
//   fetchMoreRequest<RequestTypeT>() {
//     // take current parameters and add the page property
//     final newParams = {...(request.params ?? <String, String>{})};

//     // now change the page property to the next page
//     newParams[pageProperty] =
//         (int.parse(newParams[pageProperty] ?? firstPage.toString()) + 1)
//             .toString();

//     // now put it back together
//     return request.copyWith<RequestTypeT>(
//       params: newParams,
//     );
//   }

//   /// This method defines the way we determine whether our current request has more data to fetch.
//   @override
//   bool hasMorePages(TrayRequestResponse result) {
//     return false;
//   }
// }
