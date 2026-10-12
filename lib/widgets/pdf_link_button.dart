import 'package:flutter/material.dart';
import 'package:folder_foto/widgets/pdf_view_page.dart';

class PdfLinkButton extends StatelessWidget {
  final String label;
  final String pdfUrl;

  const PdfLinkButton({
    super.key,
    required this.label,
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerPage(
              pdfUrl: pdfUrl,
              title: label,
            ),
          ),
        );
      },
      icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.blue,
        ),
      ),
    );
  }
}