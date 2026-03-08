import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'app_exporter_content.dart';
import 'app_exporter_types.dart';

class AppExporterImpl {
  static Future<ExportResult> exportApp({
    required String exportBase64,
    required String exportName,
  }) async {
    final pubspec = buildExportPubspec();
    final readme = buildExportReadme(exportName);
    final mainDart = buildExportAppMain(exportBase64);

    final archive = Archive();
    _addFile(archive, 'pubspec.yaml', pubspec);
    _addFile(archive, 'README.md', readme);
    _addFile(archive, 'lib/main.dart', mainDart);

    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) {
      return const ExportResult(message: 'Failed to create export zip', isDownload: false);
    }
    final bytes = Uint8List.fromList(zipData);
    final blob = html.Blob([bytes], 'application/zip');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$exportName.zip')
      ..click();
    html.Url.revokeObjectUrl(url);
    return const ExportResult(message: 'Download started', isDownload: true);
  }

  static void _addFile(Archive archive, String path, String contents) {
    final bytes = utf8.encode(contents);
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }
}
