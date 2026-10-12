import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          debugPrint('PDF загружен: ${details.document.pages.count} страниц');
        },
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          debugPrint('Ошибка загрузки PDF: ${details.error}');
        },
      ),
    );
  }
}