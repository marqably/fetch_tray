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

  group('tray_environment matchesDebugLevels returns correct result debugLevel',
      () {
    final trayEnvironment = TrayEnvironment();

    // test level none
    test('matchesDebugLevels requestDebugLevel.none returns correct boolean',
        () async {
      expect(
        trayEnvironment.matchesDebugLevels(
          logType: FetchTrayLogLevel.info,
          requestDebugLevel: FetchTrayDebugLevel.none,
        ),
        false,
      );
      expect(
        trayEnvironment.matchesDebugLevels(
          logType: FetchTrayLogLevel.warning,
          requestDebugLevel: FetchTrayDebugLevel.none,
        ),
        false,
      );
      expect(
        trayEnvironment.matchesDebugLevels(
          logType: FetchTrayLogLevel.error,
          requestDebugLevel: FetchTrayDebugLevel.none,
        ),
        false,
      );
    });

    // test level errors
    test(
        'matchesDebugLevels FetchTrayDebugLevel.onlyErrors returns correct boolean',
        () async {
      expect(
        trayEnvironment.matchesDebugLevels(
          logType: FetchTrayLogLevel.info,
          requestDebugLevel: FetchTrayDebugLevel.onlyErrors,
        ),
        false,
      );
      expect(
        trayEnvironment.matchesDebugLevels(
          logType: FetchTrayLogLevel.warning,
          requestDebugLevel: FetchTrayDebugLevel.onlyErrors,
        ),
        false,
      );
      expect(
        trayEnvironment.matchesDebugLevels(
          logType: FetchTrayLogLevel.error,
          requestDebugLevel: FetchTrayDebugLevel.onlyErrors,
        ),
        true,
      );
    });

    // test level errors and warnings
    test(
        'matchesDebugLevels requestDebugLevel.errorsAndWarnings returns correct boolean',
        () async {
      expect(
        trayEnvironment.matchesDebugLevels(
          logType: FetchTrayLogLevel.info,
          requestDebugLevel: FetchTrayDebugLevel.errorsAndWarnings,
        ),
        false,
      );
      expect(
        trayEnvironment.matchesDebugLevels(
          logType: FetchTrayLogLevel.warning,
          requestDebugLevel: FetchTrayDebugLevel.errorsAndWarnings,
        ),
        true,
      );
      expect(
        trayEnvironment.matchesDebugLevels(
          logType: FetchTrayLogLevel.error,
          requestDebugLevel: FetchTrayDebugLevel.errorsAndWarnings,
        ),
        true,
      );
    });

    // test level everything
    test(
        'matchesDebugLevels FetchTrayDebugLevel.everything returns correct boolean',
        () async {
      expect(
        trayEnvironment.matchesDebugLevels(
          logType: FetchTrayLogLevel.info,
          requestDebugLevel: FetchTrayDebugLevel.everything,
        ),
        true,
      );
      expect(
        trayEnvironment.matchesDebugLevels(
          logType: FetchTrayLogLevel.warning,
          requestDebugLevel: FetchTrayDebugLevel.everything,
        ),
        true,
      );
      expect(
        trayEnvironment.matchesDebugLevels(
          logType: FetchTrayLogLevel.error,
          requestDebugLevel: FetchTrayDebugLevel.everything,
        ),
        true,
      );
    });
  });

  group('tray_environment showDebugInfo returns correct result', () {
    final trayEnvironment = TrayEnvironment();

    // test local debug level, passed directly as the second parameter to the method
    test('matchesDebugLevels returns correct results for localDebugLevel',
        () async {
      expect(
        trayEnvironment.showDebugInfo(
          logType: FetchTrayLogLevel.info,
          localDebugLevel: FetchTrayDebugLevel.onlyErrors,
        ),
        false,
      );

      expect(
        trayEnvironment.showDebugInfo(
          logType: FetchTrayLogLevel.warning,
          localDebugLevel: FetchTrayDebugLevel.everything,
        ),
        true,
      );

      expect(
        trayEnvironment.showDebugInfo(
          logType: FetchTrayLogLevel.error,
          localDebugLevel: FetchTrayDebugLevel.errorsAndWarnings,
        ),
        true,
      );
    });

    // test local debug level, defined in the TrayEnvironment initialization
    test('matchesDebugLevels returns correct results for global debug level',
        () async {
      expect(
        TrayEnvironment(debugLevel: FetchTrayDebugLevel.onlyErrors)
            .showDebugInfo(logType: FetchTrayLogLevel.info),
        false,
      );

      expect(
        TrayEnvironment(debugLevel: FetchTrayDebugLevel.everything)
            .showDebugInfo(logType: FetchTrayLogLevel.warning),
        true,
      );

      expect(
        TrayEnvironment(debugLevel: FetchTrayDebugLevel.errorsAndWarnings)
            .showDebugInfo(logType: FetchTrayLogLevel.error),
        true,
      );
    });
  });
}
