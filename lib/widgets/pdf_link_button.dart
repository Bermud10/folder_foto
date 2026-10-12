import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfLinkButton extends StatelessWidget {
  final String label;
  final String pdfUrl;

  const PdfLinkButton({
    super.key,
    required this.label,
    required this.pdfUrl,
  });

  Future<void> _openPdf() async {
    final Uri url = Uri.parse(pdfUrl);
    
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView, // <-- МЕНЯЕМ ЗДЕСЬ
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true, // Иногда помогает для рендеринга
        ),
      );
    } else {
      debugPrint('Не удалось открыть PDF: $pdfUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _openPdf,
      icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}