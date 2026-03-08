import 'app_exporter_types.dart';
import 'app_exporter_io.dart' if (dart.library.html) 'app_exporter_web.dart';

class AppExporter {
  static Future<ExportResult> exportApp({
    required String exportBase64,
    required String exportName,
  }) {
    return AppExporterImpl.exportApp(
      exportBase64: exportBase64,
      exportName: exportName,
    );
  }
}
