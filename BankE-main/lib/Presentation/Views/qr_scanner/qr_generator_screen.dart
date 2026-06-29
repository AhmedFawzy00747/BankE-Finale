import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../bloc/account_bloc.dart';
import '../../bloc/account_state.dart';
import '../../../../l10n/app_localizations.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  String _qrType = 'account'; // 'account', 'iban', 'wallet', 'payment'
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _capturePngBytes() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error capturing QR image: $e");
      return null;
    }
  }

  Future<void> _saveQrCode() async {
    final bytes = await _capturePngBytes();
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to generate image bytes'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final file = await File(
              '${tempDir.path}/banke_qr_${DateTime.now().millisecondsSinceEpoch}.png')
          .create();
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('QR Code image saved to temporary path: ${file.path}'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () {
                Share.shareXFiles([XFile(file.path)], text: 'My BankE QR Code');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save QR: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _shareQrCode() async {
    final bytes = await _capturePngBytes();
    if (bytes == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/banke_qr_share.png').create();
      await file.writeAsBytes(bytes);

      Share.shareXFiles([XFile(file.path)], text: 'My BankE QR Code');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to share QR: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  String _generateQrData(String accountId, String holderName) {
    switch (_qrType) {
      case 'iban':
        return 'EG90002000000000${accountId.padLeft(8, '0')}';
      case 'wallet':
        return 'wallet_$accountId';
      case 'payment':
        final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
        final desc = Uri.encodeComponent(_descriptionController.text.trim());
        final name = Uri.encodeComponent(holderName);
        return 'banke://payment?account=$accountId&amount=$amt&recipient=$name&description=$desc';
      case 'account':
      default:
        return accountId;
    }
  }

  String _getQrDisplayData(String accountId, String holderName) {
    switch (_qrType) {
      case 'iban':
        return 'EG90002000000000${accountId.padLeft(8, '0')}';
      case 'wallet':
        return 'wallet_$accountId';
      case 'payment':
        final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
        final desc = _descriptionController.text.trim();
        return 'Payment Request:\nRecipient: $holderName\nAccount: $accountId\nAmount: \$$amt\nNote: ${desc.isEmpty ? "None" : desc}';
      case 'account':
      default:
        return 'Account ID: $accountId';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.generateQr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AccountError) {
            return Center(child: Text(state.message));
          }
          if (state is AccountLoaded) {
            final accountId = state.account.id.toString();
            final holderName = state.account.accountHolderName;
            final qrData = _generateQrData(accountId, holderName);
            final displayData = _getQrDisplayData(accountId, holderName);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // QR Image Premium Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          RepaintBoundary(
                            key: _repaintKey,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: QrImageView(
                                data: qrData,
                                version: QrVersions.auto,
                                size: 200,
                                gapless: false,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.qrTitle,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            displayData,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions wrap
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: qrData));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.copyDetails)),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: Text(l10n.copyDetails),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _saveQrCode,
                        icon: const Icon(Icons.save_alt_rounded),
                        label: Text(l10n.saveQr),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _shareQrCode,
                        icon: const Icon(Icons.share_rounded),
                        label: Text(l10n.shareQr),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Selection of type
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select QR Type'.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _qrType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: 'account', child: Text(l10n.accountNumber)),
                      DropdownMenuItem(value: 'iban', child: Text(l10n.iban)),
                      DropdownMenuItem(
                          value: 'wallet', child: Text(l10n.walletId)),
                      DropdownMenuItem(
                          value: 'payment', child: Text(l10n.paymentRequest)),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _qrType = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Dynamic payment request fields
                  if (_qrType == 'payment') ...[
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: l10n.amount,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              prefixIcon:
                                  const Icon(Icons.attach_money_rounded),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter an amount';
                              }
                              final parsed = double.tryParse(val.trim());
                              if (parsed == null || parsed <= 0) {
                                return 'Please enter a valid positive amount';
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: l10n.description,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.notes_rounded),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
