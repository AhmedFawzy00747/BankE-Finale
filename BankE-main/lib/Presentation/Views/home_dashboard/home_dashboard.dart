import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../../bloc/account_bloc.dart';
import '../../bloc/account_state.dart';
import '../../bloc/account_event.dart';
import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_state.dart';
import '../../bloc/transaction_event.dart';
import '../../../core/constants/app_constants.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_event.dart';
import '../../bloc/notification/notification_state.dart';
import '../transfer/transfer_screen.dart';
import '../payments/bill_payments_screen.dart';
import '../atm/atm_screen.dart';
import '../qr_scanner/qr_scanner_screen.dart';
import '../loans/user_loans_screen.dart';
import '../analytics/analytics_screen.dart';
import '../cards/card_management_screen.dart';
import '../notifications/notifications_screen.dart';
import '../transfers/scheduled_transfers_screen.dart';
import '../budget/budget_screen.dart';
import '../savings/saving_goals_screen.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/error_view.dart';
import '../../../../l10n/app_localizations.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with SingleTickerProviderStateMixin {
  bool _isBalanceVisible = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    context.read<NotificationBloc>().add(const FetchUnreadCountEvent());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              int unread = 0;
              if (state is NotificationLoaded) unread = state.unreadCount;
              if (state is UnreadCountLoaded) unread = state.count;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_none_rounded,
                        color: theme.primaryColor, size: 26),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ).then((_) {
                        if (mounted) {
                          context
                              .read<NotificationBloc>()
                              .add(const FetchUnreadCountEvent());
                        }
                      });
                    },
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            unread > 9 ? '9+' : unread.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AccountBloc>().add(const FetchAccountBalance(AppConstants.currentAccountId));
          context.read<TransactionBloc>().add(const FetchTransactions(AppConstants.currentAccountId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeTransition(
                  opacity: _fadeAnimation, child: _buildBalanceCard(context)),
              const SizedBox(height: 16),
              _buildActionButtons(context),
              const SizedBox(height: 20),
              _buildRecentTransactions(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
      ),
      child: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            );
          } else if (state is AccountLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.welcome}, ${state.account.accountHolderName}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const Icon(Icons.security_rounded, color: Colors.white70, size: 16),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalBalance,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 0.5),
                    ),
                    IconButton(
                      icon: Icon(
                        _isBalanceVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _isBalanceVisible = !_isBalanceVisible;
                        });
                      },
                    ),
                  ],
                ),
                Text(
                  _isBalanceVisible
                      ? '\$${state.account.balance.toStringAsFixed(2)}'
                      : '\$ ••••••',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            );
          } else if (state is AccountError) {
            return AppErrorView(message: state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            l10n.quickActions.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _actionButton(context,
                    icon: Icons.send_rounded,
                    label: l10n.transfer, onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TransferScreen()),
                  );
                }),
                _actionButton(context,
                    icon: Icons.payment_rounded,
                    label: l10n.pay, onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BillPaymentsScreen()),
                  );
                }),
                _actionButton(context,
                    icon: Icons.atm_rounded,
                    label: 'ATM', onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AtmScreen()),
                  );
                }),
                _actionButton(context,
                    icon: Icons.credit_card_rounded,
                    label: l10n.cards, onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CardManagementScreen()),
                  );
                }),
                _actionButton(context,
                    icon: Icons.qr_code_scanner_rounded,
                    label: l10n.qr, onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QrScannerScreen()),
                  );
                }),
                _actionButton(context, icon: Icons.account_balance_rounded, label: l10n.loans,
                    onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserLoansScreen()),
                  );
                }),
                _actionButton(context,
                    icon: Icons.calendar_month_rounded,
                    label: 'Scheduled', onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScheduledTransfersScreen()),
                  );
                }),
                _actionButton(context,
                    icon: Icons.pie_chart_rounded,
                    label: l10n.budgets, onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BudgetScreen()),
                  );
                }),
                _actionButton(context,
                    icon: Icons.savings_rounded,
                    label: l10n.savingGoals, onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SavingGoalsScreen()),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: primaryColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.recentTransactions,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen()),
                  );
                },
                icon: Icon(Icons.bar_chart_rounded, color: theme.primaryColor),
                tooltip: 'Spending Insights',
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Use the bottom menu to view all transactions')));
                },
                style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoading) {
                return _buildShimmerLoading();
              } else if (state is TransactionLoaded) {
                if (state.transactions.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded,
                              size: 56,
                              color: theme.dividerColor.withValues(alpha: 0.1)),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noTransactions,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final displayCount = state.transactions.length > 5
                    ? 5
                    : state.transactions.length;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayCount,
                  itemBuilder: (context, index) {
                    final tx = state.transactions[index];
                    return TransactionTile(transaction: tx);
                  },
                );
              } else if (state is TransactionError) {
                return AppErrorView(message: state.message);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
