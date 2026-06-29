import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/scheduled_transfer/scheduled_transfer_bloc.dart';
import '../../bloc/scheduled_transfer/scheduled_transfer_event.dart';
import '../../bloc/scheduled_transfer/scheduled_transfer_state.dart';
import 'create_scheduled_transfer_screen.dart';

class ScheduledTransfersScreen extends StatefulWidget {
  const ScheduledTransfersScreen({Key? key}) : super(key: key);

  @override
  _ScheduledTransfersScreenState createState() => _ScheduledTransfersScreenState();
}

class _ScheduledTransfersScreenState extends State<ScheduledTransfersScreen> {
  @override
  void initState() {
    super.initState();
    _loadTransfers();
  }

  void _loadTransfers() {
    context.read<ScheduledTransferBloc>().add(const LoadScheduledTransfersEvent());
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateScheduledTransferScreen()),
    ).then((_) {
      if (mounted) {
        _loadTransfers();
      }
    });
  }

  void _confirmCancel(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Scheduled Transfer'),
        content: const Text('Are you sure you want to cancel this scheduled transfer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.read<ScheduledTransferBloc>().add(CancelScheduledTransferEvent(id));
              Navigator.pop(ctx);
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Transfers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransfers,
          ),
        ],
      ),
      body: BlocConsumer<ScheduledTransferBloc, ScheduledTransferState>(
        listener: (context, state) {
          if (state is ScheduledTransferOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ScheduledTransferError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        buildWhen: (prev, curr) => curr is ScheduledTransferLoading || curr is ScheduledTransfersLoaded || curr is ScheduledTransferError,
        builder: (context, state) {
          if (state is ScheduledTransferLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ScheduledTransfersLoaded) {
            final transfers = state.transfers;
            if (transfers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month, size: 70, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No scheduled transfers found',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _navigateToCreate,
                      icon: const Icon(Icons.add),
                      label: const Text('Schedule Transfer'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final tx = transfers[index];
                final nextDate = DateFormat('yyyy-MM-dd HH:mm').format(tx.nextExecutionDate.toLocal());
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recipient: ${tx.receiverAccountNumber}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tx.frequency,
                                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${tx.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: theme.primaryColor,
                          ),
                        ),
                        if (tx.description != null && tx.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Note: ${tx.description}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                        const SizedBox(height: 12),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Next Execution Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(nextDate, style: const TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _confirmCancel(tx.id),
                              tooltip: 'Cancel Transfer',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (state is ScheduledTransferError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load transfers: ${state.message}'),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _loadTransfers, child: const Text('Retry')),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        child: const Icon(Icons.add),
      ),
    );
  }
}
