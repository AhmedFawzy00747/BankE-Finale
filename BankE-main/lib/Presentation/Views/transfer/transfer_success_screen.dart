import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class TransferSuccessScreen extends StatelessWidget {
  final String amount;
  final String recipient;
  final String referenceNumber;

  final GlobalKey _globalKey = GlobalKey();

  TransferSuccessScreen({
    super.key,
    required this.amount,
    required this.recipient,
    this.referenceNumber = 'TXN778234910',
  });

  Future<Uint8List> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      throw 'Error capturing receipt: $e';
    }
  }

  Future<void> _shareReceipt(BuildContext context) async {
    try {
      final bytes = await _capturePng();
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/Receipt_${referenceNumber}.png';
      final file = File(tempPath);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(tempPath, mimeType: 'image/png')],
        text: 'Transaction Receipt - $referenceNumber',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    try {
      final bytes = await _capturePng();
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!dir.existsSync()) {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      final filePath = '${dir!.path}/Receipt_${referenceNumber}.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receipt downloaded to $filePath'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save receipt: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMMM yyyy, hh:mm a').format(now);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildSuccessIcon(context),
              const SizedBox(height: 32),
              Text(
                'Transfer Successful!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your money has been sent successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 48),
              _buildReceiptCard(context, formattedDate),
              const Spacer(),
              _buildActionButtons(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.1),
            blurRadius: 40,
            spreadRadius: 10,
          )
        ],
      ),
      child: const Icon(
        Icons.check_circle_rounded,
        color: Colors.green,
        size: 100,
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, String date) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            _buildReceiptRow(context, 'Total Amount', '\$$amount', isTotal: true),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(thickness: 1),
            ),
            _buildReceiptRow(context, 'Recipient Account', recipient),
            const SizedBox(height: 16),
            _buildReceiptRow(context, 'Transaction ID', referenceNumber),
            const SizedBox(height: 16),
            _buildReceiptRow(context, 'Date & Time', date),
            const SizedBox(height: 16),
            _buildReceiptRow(context, 'Status', 'Completed', isStatus: true),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _downloadReceipt(context);
                },
                icon: const Icon(Icons.download_rounded, size: 20),
                label: const Text(
                  'Download',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _shareReceipt(context);
                },
                icon: const Icon(Icons.share_outlined, size: 20),
                label: const Text(
                  'Share Receipt',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReceiptRow(BuildContext context, String label, String value,
      {bool isTotal = false, bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal || isStatus ? FontWeight.w900 : FontWeight.bold,
            fontSize: isTotal ? 22 : 14,
            color: isStatus ? Colors.green : Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ],
    );
  }
}
