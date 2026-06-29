import 'package:contr_project/domain/entities/budget_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/budget/budget_bloc.dart';
import '../../bloc/budget/budget_event.dart';
import '../../bloc/budget/budget_state.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _month = DateTime.now().month;
  final _year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadBudgetProgress();
  }

  void _loadBudgetProgress() {
    context
        .read<BudgetBloc>()
        .add(LoadBudgetProgressEvent(month: _month, year: _year));
  }

  void _showSetBudgetDialog(BuildContext context,
      {int? id, String? defaultCategory, double? currentLimit, double? currentSpent}) {
    final formKey = GlobalKey<FormState>();
    final amountController =
        TextEditingController(text: currentLimit?.toString() ?? '');
    String selectedCategory = defaultCategory ?? 'Food & Dining';

    final List<String> categories = [
      'Food & Dining',
      'Utilities',
      'Shopping',
      'Entertainment',
      'Transfers',
      'Miscellaneous'
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            Text(id == null ? 'Set Category Budget' : 'Edit Category Budget'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (defaultCategory == null)
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) selectedCategory = val;
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Category: $selectedCategory',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monthly Limit (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty)
                    return 'Enter limit amount';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0)
                    return 'Enter a valid positive number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final limit = double.parse(amountController.text.trim());
                if (id != null) {
                  context.read<BudgetBloc>().add(
                        UpdateBudgetEvent(
                          id: id,
                          category: selectedCategory,
                          amount: limit,
                          spentAmount: currentSpent,
                          month: _month,
                          year: _year,
                        ),
                      );
                } else {
                  context.read<BudgetBloc>().add(
                        CreateBudgetEvent(
                          category: selectedCategory,
                          amount: limit,
                          month: _month,
                          year: _year,
                        ),
                      );
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, BudgetProgressEntity prog) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Expense: ${prog.category}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Expense Amount (\$)',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Enter amount';
              final parsed = double.tryParse(val.trim());
              if (parsed == null || parsed <= 0) return 'Enter a valid positive number';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final expense = double.parse(amountController.text.trim());
                context.read<BudgetBloc>().add(
                      UpdateBudgetEvent(
                        id: prog.id!,
                        category: prog.category,
                        amount: prog.limitAmount,
                        spentAmount: prog.spentAmount + expense,
                        month: _month,
                        year: _year,
                      ),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showUpdateSpentDialog(BuildContext context, BudgetProgressEntity prog) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(text: prog.spentAmount.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Spent Amount: ${prog.category}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Spent Amount (\$)',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Enter amount';
              final parsed = double.tryParse(val.trim());
              if (parsed == null || parsed < 0) return 'Enter a valid number';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final spent = double.parse(amountController.text.trim());
                context.read<BudgetBloc>().add(
                      UpdateBudgetEvent(
                        id: prog.id!,
                        category: prog.category,
                        amount: prog.limitAmount,
                        spentAmount: spent,
                        month: _month,
                        year: _year,
                      ),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBudgetActionsSheet(
      BuildContext context, BudgetProgressEntity prog) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle_outline_rounded),
              title: const Text('Add Expense'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddExpenseDialog(context, prog);
              },
            ),
            ListTile(
              leading: const Icon(Icons.adjust_rounded),
              title: const Text('Update Spent Amount'),
              onTap: () {
                Navigator.pop(ctx);
                _showUpdateSpentDialog(context, prog);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Budget Limit'),
              onTap: () {
                Navigator.pop(ctx);
                _showSetBudgetDialog(
                  context,
                  id: prog.id,
                  defaultCategory: prog.category,
                  currentLimit: prog.limitAmount,
                  currentSpent: prog.spentAmount,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Budget',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteBudget(context, prog.id!);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteBudget(BuildContext context, int budgetId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Budget'),
        content:
            const Text('Are you sure you want to delete this category budget?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<BudgetBloc>().add(
                    DeleteBudgetEvent(id: budgetId, month: _month, year: _year),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = DateFormatMonth(_month);

    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Budget ($monthName $_year)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBudgetProgress,
          ),
        ],
      ),
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is BudgetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        buildWhen: (prev, curr) =>
            curr is BudgetLoading ||
            curr is BudgetProgressLoaded ||
            curr is BudgetError,
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BudgetProgressLoaded) {
            final progressList = state.progressList;
            if (progressList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance,
                        size: 70, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No category budgets configured yet',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showSetBudgetDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Set a Budget'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: progressList.length,
              itemBuilder: (context, index) {
                final prog = progressList[index];
                final percentFraction = prog.percentage / 100;
                final percent = percentFraction > 1.0
                    ? 1.0
                    : (percentFraction < 0.0 ? 0.0 : percentFraction);
                final bool isWarning =
                    prog.spentAmount >= prog.limitAmount * 0.85;

                Color progressColor = theme.primaryColor;
                if (prog.isExceeded) {
                  progressColor = Colors.redAccent;
                } else if (isWarning) {
                  progressColor = Colors.orangeAccent;
                }

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (prog.id != null) {
                        _showBudgetActionsSheet(context, prog);
                      } else {
                        _showSetBudgetDialog(context,
                            defaultCategory: prog.category);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prog.category,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              if (prog.isExceeded)
                                const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        color: Colors.redAccent, size: 18),
                                    SizedBox(width: 4),
                                    Text(
                                      'Exceeded!',
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ],
                                )
                              else if (isWarning)
                                const Text(
                                  'Near Limit',
                                  style: TextStyle(
                                      color: Colors.orangeAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Spent: \$${prog.spentAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Limit: \$${prog.limitAmount.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percent,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(progressColor),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${prog.percentage.toStringAsFixed(0)}% used',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: progressColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Remaining: \$${(prog.limitAmount - prog.spentAmount).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      (prog.limitAmount - prog.spentAmount) >= 0
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          if (state is BudgetError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load budgets: ${state.message}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      onPressed: _loadBudgetProgress,
                      child: const Text('Retry')),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSetBudgetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  String DateFormatMonth(int monthNum) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    if (monthNum >= 1 && monthNum <= 12) {
      return months[monthNum - 1];
    }
    return '';
  }
}
