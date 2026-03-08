class ExportResult {
  final String? path;
  final String message;
  final bool isDownload;

  const ExportResult({
    required this.message,
    this.path,
    this.isDownload = false,
  });
}
