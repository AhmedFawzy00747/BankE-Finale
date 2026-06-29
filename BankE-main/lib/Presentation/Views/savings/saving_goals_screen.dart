import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/saving_goal_entity.dart';
import '../../bloc/saving_goal/saving_goal_bloc.dart';
import '../../bloc/saving_goal/saving_goal_event.dart';
import '../../bloc/saving_goal/saving_goal_state.dart';
import '../../bloc/account_bloc.dart';
import '../../bloc/account_event.dart';
import '../../../core/constants/app_constants.dart';

class SavingGoalsScreen extends StatefulWidget {
  const SavingGoalsScreen({Key? key}) : super(key: key);

  @override
  _SavingGoalsScreenState createState() => _SavingGoalsScreenState();
}

class _SavingGoalsScreenState extends State<SavingGoalsScreen> {
  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() {
    context.read<SavingGoalBloc>().add(const LoadSavingGoalsEvent());
  }

  void _showAddGoalDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final targetAmountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('New Saving Goal'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter goal name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: targetAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Target Amount (\$)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter target amount';
                    final parsed = double.tryParse(val.trim());
                    if (parsed == null || parsed <= 0) return 'Enter valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setStateDialog(() => selectedDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: Text('Target Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<SavingGoalBloc>().add(
                    CreateSavingGoalEvent(
                      name: nameController.text.trim(),
                      targetAmount: double.parse(targetAmountController.text.trim()),
                      targetDate: selectedDate,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFundsDialog(int goalId, String goalName) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Fund "$goalName"'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Transfer Amount (\$)',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Enter amount to transfer';
              final parsed = double.tryParse(val.trim());
              if (parsed == null || parsed <= 0) return 'Enter valid positive number';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amt = double.parse(amountController.text.trim());
                context.read<SavingGoalBloc>().add(
                  AddSavingGoalFundsEvent(goalId: goalId, amount: amt),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Transfer Funds'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawFundsDialog(int goalId, String goalName, double currentAmount) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Withdraw from "$goalName"'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available to withdraw: \$${currentAmount.toStringAsFixed(2)}', 
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Withdraw Amount (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter amount to withdraw';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Enter valid positive number';
                  if (parsed > currentAmount) return 'Requested amount exceeds saved amount';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amt = double.parse(amountController.text.trim());
                context.read<SavingGoalBloc>().add(
                  WithdrawSavingGoalFundsEvent(goalId: goalId, amount: amt),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(SavingGoalEntity goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SavingGoalBloc>(),
          child: EditSavingGoalScreen(goal: goal),
        ),
      ),
    );
  }

  void _confirmDeleteGoal(int goalId, String goalName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Saving Goal'),
        content: Text('Are you sure you want to delete "$goalName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          TextButton(
            onPressed: () {
              context.read<SavingGoalBloc>().add(DeleteSavingGoalEvent(goalId));
              Navigator.pop(ctx);
            },
            child: const Text('Yes, Delete', style: TextStyle(color: Colors.red)),
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
        title: const Text('Saving Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGoals,
          ),
        ],
      ),
      body: BlocConsumer<SavingGoalBloc, SavingGoalState>(
        listener: (context, state) {
          if (state is SavingGoalOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<AccountBloc>().add(const FetchAccountBalance(AppConstants.currentAccountId));
          } else if (state is SavingGoalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        buildWhen: (prev, curr) => curr is SavingGoalLoading || curr is SavingGoalsLoaded || curr is SavingGoalError,
        builder: (context, state) {
          if (state is SavingGoalLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SavingGoalsLoaded) {
            final goals = state.goals;
            if (goals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.savings_outlined, size: 70, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No saving goals established yet',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showAddGoalDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Goal'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final double percent = (goal.completionPercentage / 100).clamp(0.0, 1.0);
                final dateText = DateFormat('yyyy-MM-dd').format(goal.targetDate.toLocal());
                
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
                            Expanded(
                              child: Text(
                                goal.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                if (goal.isCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Completed! 🎉',
                                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (val) {
                                    if (val == 'fund') {
                                      _showAddFundsDialog(goal.id, goal.name);
                                    } else if (val == 'withdraw') {
                                      _showWithdrawFundsDialog(goal.id, goal.name, goal.currentAmount);
                                    } else if (val == 'edit') {
                                      _showEditGoalDialog(goal);
                                    } else if (val == 'delete') {
                                      _confirmDeleteGoal(goal.id, goal.name);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'fund',
                                      child: ListTile(
                                        leading: Icon(Icons.add),
                                        title: Text('Add Funds'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'withdraw',
                                      child: ListTile(
                                        leading: Icon(Icons.remove),
                                        title: Text('Withdraw Funds'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Edit Goal'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete, color: Colors.red),
                                        title: Text('Delete Goal', style: TextStyle(color: Colors.red)),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Saved Amount', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text('\$${goal.currentAmount.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: theme.primaryColor)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Target Amount', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text('\$${goal.targetAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(goal.isCompleted ? Colors.green : theme.primaryColor),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${goal.completionPercentage.toStringAsFixed(2)}% achieved',
                              style: TextStyle(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Target date: $dateText',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
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

          if (state is SavingGoalError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load saving goals: ${state.message}'),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _loadGoals, child: const Text('Retry')),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditSavingGoalScreen extends StatefulWidget {
  final SavingGoalEntity goal;

  const EditSavingGoalScreen({Key? key, required this.goal}) : super(key: key);

  @override
  _EditSavingGoalScreenState createState() => _EditSavingGoalScreenState();
}

class _EditSavingGoalScreenState extends State<EditSavingGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _targetAmountController = TextEditingController(text: widget.goal.targetAmount.toStringAsFixed(2));
    _selectedDate = widget.goal.targetDate.toLocal();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amt = double.parse(_targetAmountController.text.trim());
      context.read<SavingGoalBloc>().add(
        UpdateSavingGoalEvent(
          goalId: widget.goal.id,
          name: _nameController.text.trim(),
          targetAmount: amt,
          targetDate: _selectedDate,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Saving Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.savings_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter goal name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Target Amount (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter target amount';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Enter valid target amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().isBefore(_selectedDate) ? DateTime.now() : _selectedDate,
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_month),
                label: Text('Target Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
