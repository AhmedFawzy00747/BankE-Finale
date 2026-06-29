class ScheduledTransferEntity {
  final int id;
  final String receiverAccountNumber;
  final double amount;
  final String? description;
  final DateTime scheduledDate;
  final String frequency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastExecutedAt;
  final DateTime nextExecutionDate;

  const ScheduledTransferEntity({
    required this.id,
    required this.receiverAccountNumber,
    required this.amount,
    this.description,
    required this.scheduledDate,
    required this.frequency,
    required this.isActive,
    required this.createdAt,
    this.lastExecutedAt,
    required this.nextExecutionDate,
  });
}
