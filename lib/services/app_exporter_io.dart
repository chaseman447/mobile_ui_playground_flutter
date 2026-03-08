import 'dart:io';
import 'dart:developer' as developer;

import 'package:path_provider/path_provider.dart';

import 'app_exporter_content.dart';
import 'app_exporter_types.dart';

class AppExporterImpl {
  static Future<ExportResult> exportApp({
    required String exportBase64,
    required String exportName,
  }) async {
    developer.log('AppExporter: Starting export process', name: 'Export');

    try {
      // Get the actual Downloads directory that users can access
      Directory? downloadsDir;
      
      // Try to get Downloads directory first
      try {
        downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          developer.log('AppExporter: Downloads directory found: ${downloadsDir.path}', name: 'Export');
        }
      } catch (e) {
        developer.log('AppExporter: getDownloadsDirectory failed: $e', name: 'Export');
      }

      // If Downloads not available, try to construct it manually for Android
      if (downloadsDir == null) {
        try {
          // Android standard Downloads path
          final externalStorage = await getExternalStorageDirectory();
          if (externalStorage != null) {
            // Try multiple possible Download locations
            final possiblePaths = [
              '${externalStorage.path}/Download',           // Some Android versions
              '${externalStorage.path}/Downloads',         // Standard
              '/storage/emulated/0/Download',          // Direct path
              '/storage/emulated/0/Downloads',         // Direct path
              '/sdcard/Download',                      // Alternative
              '/sdcard/Downloads',                     // Alternative
            ];

            for (final path in possiblePaths) {
              final testDir = Directory(path);
              if (await testDir.exists()) {
                downloadsDir = testDir;
                developer.log('AppExporter: Found Downloads at: $path', name: 'Export');
                break;
              }
            }

            // If still not found, create it in external storage
            if (downloadsDir == null && externalStorage != null) {
              downloadsDir = Directory('${externalStorage.path}/Downloads');
              await downloadsDir.create(recursive: true);
              developer.log('AppExporter: Created Downloads directory: ${downloadsDir.path}', name: 'Export');
            }
          }
        } catch (e) {
          developer.log('AppExporter: Manual Downloads path failed: $e', name: 'Export');
        }
      }

      // Final fallback to app documents
      if (downloadsDir == null) {
        final appDocsDir = await getApplicationDocumentsDirectory();
        downloadsDir = Directory('${appDocsDir.path}/Downloads');
        await downloadsDir.create(recursive: true);
        developer.log('AppExporter: Using app documents Downloads: ${downloadsDir.path}', name: 'Export');
      }

      final exportDirName = '${exportName}_export';
      final exportDir = Directory('${downloadsDir.path}/$exportDirName');
      await exportDir.create(recursive: true);
      final libDir = Directory('${exportDir.path}/lib');
      await libDir.create(recursive: true);

      developer.log('AppExporter: Final export path: ${exportDir.path}', name: 'Export');

      final pubspec = buildExportPubspec();
      final readme = buildExportReadme(exportDirName);
      final mainDart = buildExportAppMain(exportBase64);

      final pubspecFile = File('${exportDir.path}/pubspec.yaml');
      final mainDartFile = File('${libDir.path}/main.dart');
      final readmeFile = File('${exportDir.path}/README.md');

      await pubspecFile.writeAsString(pubspec);
      await mainDartFile.writeAsString(mainDart);
      await readmeFile.writeAsString(readme);

      // Verify files
      final pubspecExists = pubspecFile.existsSync();
      final mainDartExists = mainDartFile.existsSync();
      final readmeExists = readmeFile.existsSync();

      developer.log('AppExporter: Files verified - pubspec: $pubspecExists, main.dart: $mainDartExists, README: $readmeExists', name: 'Export');

      if (!pubspecExists || !mainDartExists || !readmeExists) {
        throw Exception('Files were not created successfully');
      }

      // Get file sizes for confirmation
      final pubspecSize = pubspecFile.lengthSync();
      final mainDartSize = mainDartFile.lengthSync();
      final readmeSize = readmeFile.lengthSync();

      developer.log('AppExporter: File sizes - pubspec: $pubspecSize bytes, main.dart: $mainDartSize bytes, README: $readmeSize bytes', name: 'Export');

      return ExportResult(
        message: '✅ Exported to Downloads folder!\n\n📁 Location: Downloads/$exportDirName\n\n� Files created:\n• pubspec.yaml ($pubspecSize bytes)\n• lib/main.dart ($mainDartSize bytes)\n• README.md ($readmeSize bytes)\n\nCheck your Downloads folder in File Manager.',
        path: exportDir.path,
        isDownload: false
      );
    } catch (e, stackTrace) {
      developer.log('AppExporter: Error during export: $e', name: 'Export', error: e, stackTrace: stackTrace);
      return ExportResult(
        message: '❌ Export failed: $e\n\nPlease check app storage permissions and try again.',
        path: '',
        isDownload: false
      );
    }
  }
}
