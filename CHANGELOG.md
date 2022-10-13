# Changelog

## 0.0.1

* First release
* Support for hooks
* Simple development output logging

## 0.0.2

* Added better debugging options

## 0.0.3

* Added no debug logging as default for test runs

## 0.0.4

* Added `getUrl` method to `TrayRequest` to be able to customize more complex URL patterns

## 0.0.5

* Added `getParams` method to `TrayRequest` to be able to customize more complex param combinations

## 0.0.6

* Added `requestParams` param to `getParams` method in `TrayRequest`

## 0.0.7

* Fixed `Response` json encoding to utf-8 for testing tray responses, to fix error issue with non latin json contents.

## 0.0.8

* Added `fetchMore` method

## 0.0.9

* Improved `refetch` functionality

## 0.1.0

* Added custom metadata type functionality

## 0.1.1

* Fixed tests for metadata type functionality

## 0.2.0

* Made all `getParams`, `getUrl`, ... async

## 0.2.1

* Fixed handling of empty response bodies

## 0.2.2

* Small bugfixes

## 0.2.3

* Fixed tests after async change of `getParams`, `getUrl`, ... (thanks to [@lukasbachlechner] (<https://www.github.com/lukasbachlechner)> for that)
