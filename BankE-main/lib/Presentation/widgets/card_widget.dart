import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/card_entity.dart';
import '../bloc/card/card_bloc.dart';
import '../bloc/card/card_event.dart';
import '../../../core/constants/app_constants.dart';

class CardWidget extends StatelessWidget {
  final CardEntity card;
  final VoidCallback onFreezeToggle;
  final VoidCallback onDelete;

  const CardWidget({
    super.key,
    required this.card,
    required this.onFreezeToggle,
    required this.onDelete,
  });

  void _showCardDetails(BuildContext context) {
    final fullNumber = card.cardNumber.isNotEmpty ? card.cardNumber : '????';
    final formattedNumber = fullNumber.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ").trim();
    final last4 = card.cardNumber.length >= 4 ? card.cardNumber.substring(card.cardNumber.length - 4) : '????';
    final holder = card.cardHolderName.isNotEmpty ? card.cardHolderName : '—';
    final expiry = card.expiryDate.isNotEmpty ? card.expiryDate : '—';
    final cvv = card.cvv.isNotEmpty ? card.cvv : '***';
    final cardType = card.cardType.isNotEmpty ? card.cardType : '—';
    final statusLabel = card.isFrozen ? 'Frozen' : 'Active';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CardBloc>(),
        child: _CardDetailsSheet(
          card: card,
          fullNumber: formattedNumber,
          last4: last4,
          holder: holder,
          expiry: expiry,
          cvv: cvv,
          cardType: cardType,
          statusLabel: statusLabel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullNumber = card.cardNumber.isNotEmpty ? card.cardNumber : '????';
    final String formattedNumber = fullNumber.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ").trim();
    final holder = card.cardHolderName.isNotEmpty ? card.cardHolderName : '—';
    final expiry = card.expiryDate.isNotEmpty ? card.expiryDate : '—';

    final List<Color> gradientColors = card.isFrozen
        ? [Colors.grey.shade400, Colors.grey.shade600]
        : (card.cardType.toLowerCase() == 'credit'
            ? [const Color(0xFF1E3C72), const Color(0xFF2A5298)]
            : [const Color(0xFF009FFF), const Color(0xFFec2F4B)]);

    return GestureDetector(
      onTap: () => _showCardDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.45),
              blurRadius: 16.0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: card label + chip icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.isVirtual
                            ? 'Virtual ${card.cardType} Card'
                            : '${card.cardType} Card',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (card.isFrozen)
                        const Text(
                          'FROZEN',
                          style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                    ],
                  ),
                  Icon(
                    card.isFrozen ? Icons.ac_unit : Icons.credit_card,
                    color: Colors.white.withValues(alpha: 0.85),
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 28.0),

              // Card number row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Tap hint
                  Row(
                    children: [
                      Icon(Icons.touch_app,
                          color: Colors.white.withValues(alpha: 0.6), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Details',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Bottom row: holder + expiry + actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoColumn('Card Holder', holder),
                  _infoColumn('Expires', expiry),
                  // Actions
                  Row(
                    children: [
                      _actionButton(
                        icon: card.isFrozen ? Icons.play_arrow : Icons.pause,
                        label: card.isFrozen ? 'Unfreeze' : 'Freeze',
                        onTap: onFreezeToggle,
                      ),
                      const SizedBox(width: 6),
                      _actionButton(
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        onTap: onDelete,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11.0,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon,
              color: isDestructive ? Colors.redAccent : Colors.white, size: 20),
          Text(
            label,
            style: TextStyle(
              color: isDestructive ? Colors.redAccent : Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Details bottom sheet ───────────────────────────────────────────────────────

// ── Details bottom sheet ───────────────────────────────────────────────────────

class _CardDetailsSheet extends StatefulWidget {
  final CardEntity card;
  final String fullNumber;
  final String last4;
  final String holder;
  final String expiry;
  final String cvv;
  final String cardType;
  final String statusLabel;

  const _CardDetailsSheet({
    required this.card,
    required this.fullNumber,
    required this.last4,
    required this.holder,
    required this.expiry,
    required this.cvv,
    required this.cardType,
    required this.statusLabel,
  });

  @override
  State<_CardDetailsSheet> createState() => _CardDetailsSheetState();
}

class _CardDetailsSheetState extends State<_CardDetailsSheet> {
  late bool _online;
  late bool _atm;
  late bool _international;
  late CardBloc _cardBloc;

  @override
  void initState() {
    super.initState();
    _online = widget.card.onlinePaymentsEnabled;
    _atm = widget.card.atmWithdrawalsEnabled;
    _international = widget.card.internationalTransactionsEnabled;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cardBloc = BlocProvider.of<CardBloc>(context);
  }

  void _copy(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateControls() {
    _cardBloc.add(
      UpdateCardControlsEvent(
        cardId: widget.card.id,
        accountId: AppConstants.currentAccountId,
        online: _online,
        atm: _atm,
        international: _international,
      ),
    );
  }

  void _showChangePinDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Card PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(
            hintText: 'Enter new 4-digit PIN',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newPin = pinController.text.trim();
              if (newPin.length == 4 && int.tryParse(newPin) != null) {
                _cardBloc.add(
                  ChangeCardPinEvent(
                    cardId: widget.card.id,
                    accountId: AppConstants.currentAccountId,
                    pin: newPin,
                  ),
                );
                Navigator.pop(ctx);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN must be exactly 4 digits'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(Icons.credit_card, size: 22),
              const SizedBox(width: 10),
              Text(
                'Card Controls & Details',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Toggle card payment channels or update details securely.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Divider(),

          // Card Controls Section
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text('Online Payments', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Enable online transactions & e-commerce'),
            trailing: Switch.adaptive(
              value: _online,
              onChanged: (val) {
                setState(() => _online = val);
                _updateControls();
              },
              activeThumbColor: theme.primaryColor,
              activeTrackColor: theme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.atm),
            title: const Text('ATM Withdrawals', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Allow cash withdrawals at ATM machines'),
            trailing: Switch.adaptive(
              value: _atm,
              onChanged: (val) {
                setState(() => _atm = val);
                _updateControls();
              },
              activeThumbColor: theme.primaryColor,
              activeTrackColor: theme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.public),
            title: const Text('International Transactions', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Permit transactions outside local country'),
            trailing: Switch.adaptive(
              value: _international,
              onChanged: (val) {
                setState(() => _international = val);
                _updateControls();
              },
              activeThumbColor: theme.primaryColor,
              activeTrackColor: theme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const Divider(),

          // Details List
          _detailRow(context, 'Card Number', widget.fullNumber, widget.fullNumber.replaceAll(' ', '')),
          _detailRow(context, 'CVV', widget.cvv, widget.cvv),
          _detailRow(context, 'Card Holder', widget.holder, widget.holder),
          _detailRow(context, 'Expiry Date', widget.expiry, widget.expiry),
          _detailRow(context, 'PIN', widget.card.pin, widget.card.pin),
          _detailRow(context, 'Card Type', widget.cardType, widget.cardType),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showChangePinDialog,
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: const Text('Change PIN'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
      BuildContext context, String label, String display, String copyValue) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 3),
                Text(display,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          ),
          if (copyValue != '—')
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy $label',
              onPressed: () => _copy(context, copyValue, label),
              color: theme.primaryColor,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
