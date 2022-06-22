import 'package:fetch_tray/contracts/tray_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tray_environment getCombinedHeaders', () {
    final trayEnvironment = TrayEnvironment(
      headers: {'testheader': 'testheader_value'},
    );
    final Map<String, String> exampleHeaders = {
      'customparam1': 'customparam1_value',
      'customparam2': 'customparam2_value',
    };

    /// the getCombinedHeaders should method should return only the custom
    /// headers, if no client headers are given
    test(
        'getCombinedHeaders returns only default headers if no custom ones given',
        () async {
      expect(
        // overwrite the client with an empty custom request header map
        trayEnvironment.getCombinedHeaders({}),
        {
          'testheader': 'testheader_value',
        },
      );
    });

    /// the getCombinedHeaders should method should return only the custom
    /// headers, if no client headers are given
    test(
        'getCombinedHeaders returns only default params if no client headers are given',
        () async {
      expect(
        // create a new client here, that has no default headers
        TrayEnvironment(
          headers: {},
        ).getCombinedHeaders(exampleHeaders),
        {
          'customparam1': 'customparam1_value',
          'customparam2': 'customparam2_value',
        },
      );
    });

    /// the getCombinedHeaders should method should override default headers,
    /// if a custom header with exactly the same name is given
    test(
        'getCombinedHeaders returns overrides default headers if same custom given',
        () async {
      expect(
        // create a new client here, that has no default headers
        TrayEnvironment(
          headers: {},
        ).getCombinedHeaders(exampleHeaders),
        {
          'customparam1': 'customparam1_value',
          'customparam2': 'customparam2_value',
        },
      );
    });

    /// the getCombinedHeaders should method should combine the headers if both are given
    test('getCombinedHeaders combines both maps if both are given', () async {
      expect(
        // overwrite the client with an empty custom request header map
        trayEnvironment.getCombinedHeaders(exampleHeaders),
        {
          'testheader': 'testheader_value',
          'customparam1': 'customparam1_value',
          'customparam2': 'customparam2_value',
        },
      );
    });

    /// the getCombinedHeaders method should overwrite client headers with
    /// custom headers if there is an overlap in map keys
    test('getCombinedHeaders custom headers overwrite client headers',
        () async {
      // add an overlapping exampleHeader key
      exampleHeaders['testheader'] = 'testheader_overwritten';

      expect(
        // overwrite the client with an empty custom request header map
        trayEnvironment.getCombinedHeaders(exampleHeaders),
        {
          'testheader': 'testheader_overwritten',
          'customparam1': 'customparam1_value',
          'customparam2': 'customparam2_value',
        },
      );
    });
  });
}
