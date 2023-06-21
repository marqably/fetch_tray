import 'package:http/http.dart' as http;

export 'src/contracts/contracts.dart';
export 'src/interfaces/interfaces.dart';
export 'src/pagination_drivers/pagination_drivers.dart';
export 'src/utils/utils.dart';
export 'src/fetch_tray_base.dart';

// export http client to make it easier to import it
typedef HttpClient = http.Client;
