# Pagination with FetchTray

The concept of fetching more data is deeply implemented in fetch_tray.

TODO: add more information on how to do traditional pagination with prevPage/nextPage (although this is easily doable outside of fetch_tray, by reloading with a decreased/increased page parameter)

## FetchMore

One of the core requirements for a lot of modern apps today is being able to show an infinite scrolling list or lists, that keep loading data the further you go down.
This is why fetch_tray offers support for these kinds of requests right out of the box using the `fetchMore` method.

It requires a little bit of extra setup, but allows you then to just call `myRequest.fetchMore()` on a request and it will automatically combine your old and new request and take care of pagination.

**Disclaimer:**
Full fetchMore functionality is only available using the hook implementation, because this is where the real magic happens.
If you want to build this without hooks, you can just take the hooks as an example or just merge the old state with new state on fetching.

## Pagination Drivers

The actual logic for pagination in fetch_tray is done using `PaginationDrivers`.
These are classes, that contain logic for the most common pagination techniques (like page based pagination, offset based pagination, ...) and do the heavy lifting for standard solution.

If you need a special solution or one of our prebuilt drivers doesn't work for you, you can easily create your own driver, by just using extending the `FetchTrayPaginationDriver` class and defining the methods needed in there.

// TODO: build a offset based pagination driver

## Adding a pagination driver to your requests

The first step to implement pagination in your application is defining the `PaginationDriver` you want to use.
You can either define a custom driver per request in the request class or (as we would recommend) define it in your abstracted AppRequest environment, that you all of your requests from.

```dart
// my_api_tray_request.dart

import 'package:fetch_tray/fetch_tray.dart';

class MyApiTrayRequest<ResultType> extends TrayRequest<ResultType> {
  ...
  @override
  TrayEnvironment getEnvironment() {
    return TrayEnvironment(
      ...
    );
  }
  ...

  // This is where you can define your prefered PaginationDriver based on the way your api handles pagination
  // here for example we use the page based driver
  @override
  FetchTrayPaginationDriver<RequestType, ResultType>
      pagination<RequestType extends TrayRequest>(RequestType request) {
        // It is enough to just use the correct driver class here in the return statement!
    return PagePaginationDriver<RequestType, ResultType>(request);
  }  
}
```

## Adding a metadata converter

To do pagination right, we need a few meta data like `are there more pages`, `what page are one`, ... .
To make sure we can work with this no matter what the api format is, you can also define that in your request or app wide request base using the following method where you map your api to fetch_trays Metadata Format.

```dart
// my_api_tray_request.dart

import 'package:fetch_tray/fetch_tray.dart';

class MyApiTrayRequest<ResultType> extends TrayRequest<ResultType> {
  ...
  @override
  TrayEnvironment getEnvironment() {
    ..
  }
  @override
  FetchTrayPaginationDriver<RequestType, ResultType>
      pagination<RequestType extends TrayRequest>(RequestType request) {
     ...
  }

  ...

  /// Returns the requests pagination meta information, used for controlling and showing paginated data
  @override
  TrayRequestMetadata? generateMetaData<RequestType extends TrayRequest>(
      RequestType request,
      dynamic responseJson,
    ) {
    final currentParams = request.getParams();

    return TrayRequestMetadata(
        currentPage: int.parse(responseJson['page']),
        limit: currentParams?['limit'],
        totalPages: int.parse(responseJson['totalPages']),
        totalResults: int.parse(responseJson['resultCount']),
        hasNextPage: int.parse(responseJson['page']) < int.parse(responseJson['totalPages']),
        hasPreviousPage: int.parse(responseJson['page']) > 1,
    );
  }  
}
```

With this we already have implemented the biggest part of pagination for our whole application.
Of course some details (metadata params, ...) can differ form request to request if your api does
not always output the exact same structure, but you can easily fix that by defining or overwriting it
in the specific requests or worst case split your base Request definition `MyApiTrayRequest` into different configurations bases on the structure.

### Defining how a merge should happened

Now we have defined what pagination method to use and how we get the metadata.
The last missing part is how the data from old and new requests should be merged together.
There might be differences. In most cases, you will add the new entries at the end or the start of your old entries List.

This alone is a choice you should be able to configure. Sometimes you want to do more or something different.
This (and type safety limits in flutter) and the fact, that you should be able to customize it, if you want is why you need to implement a function to handle that in all of your paginatable requests.

Also you have to add the mixin `with Paginatable<YOUR_RESULT_TYPE>`

In most cases it will be the very simple method:

```dart
/// here we added the `with Paginatable<List<User>>` part
class FetchUsersRequest extends MyApiTrayRequest<List<User>> with Paginatable<List<User>>  {
  FetchUserRequest({
    Map<String, String>? params,
  }) : 
  super(
          url: '/api/user/:userId',
          method: MakeRequestMethod.get,
          params: {
            ...params,
          },
        );

  @override
  User getModelFromJson(dynamic json) {
    return User.fromJson(json);
  }
    
  // this is the method we need to add.
  // Here we create a new List on all of the old entries + add the end all of the new entries
  // So we just add the new entries, to all of the existing ones.
  @override
  List<User> mergePaginatedResults(
      List<User> currentData, List<User> newData) {
    return [...currentData, ...newData];
  }
}
```

This is something, at least for now, you need to implement on a request level, because otherwise you cannot get the types to work right!

## Fetching more data

When all of this is done, fetching more data is as easy as just calling:

```dart

class MyUserList extends HookWidget {
  const MyUserList({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final usersRequest = useGetUsersGroupedRequest(
      limit: 10,
    );
    
    return Column(children: [
        UserList(users: userRequest.data),

        // check if we have more data
        if (usersRequest.metadata.hasMorePages)
            Button(
                label: 'Load more',
                onPress: () {
                    // call the fetchMore method
                    usersRequest.fetchMore();
                }
            )
    );
  }
}
```

## Showing a loading indicator or sceleton screen, while loading more

Generally the loading behavior will differ a bit from the normal loading behavior.
For that reason, you will find the FetchRequest property `fetchMoreLoading` that you can use to indicate whether we are currently loading more on not.

With this you should be able to easily add the expected behavior:

```dart

class MyUserList extends HookWidget {
  const MyUserList({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final usersRequest = useGetUsersGroupedRequest(
      limit: 10,
    );
    
    return Column(children: [
        UserList(users: userRequest.data),
        if (usersRequest.metadata.hasMorePages)
            Button(
                label: 'Load more',
                onPress: () {
                    usersRequest.fetchMore();
                }
            )

        // if fetch more loading is taking place right now -> showing loading indicator
        if (usersRequest.fetchMoreLoading) {
          CircularProgressIndicator(),
        }
    );
  }
}
```
