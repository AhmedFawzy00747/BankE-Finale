import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class StatementViewerScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  final String title;

  const StatementViewerScreen({
    Key? key,
    required this.pdfBytes,
    required this.title,
  }) : super(key: key);

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      final filePath = '${dir!.path}/${title.replaceAll(' ', '_')}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to $filePath'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/${title.replaceAll(' ', '_')}.pdf';
      final file = File(tempPath);
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(tempPath, mimeType: 'application/pdf')],
        text: title,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Download PDF',
            onPressed: () => _downloadPdf(context),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share PDF',
            onPressed: () => _sharePdf(context),
          ),
        ],
      ),
      body: SfPdfViewer.memory(pdfBytes),
    );
  }
}
