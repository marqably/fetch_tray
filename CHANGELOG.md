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
