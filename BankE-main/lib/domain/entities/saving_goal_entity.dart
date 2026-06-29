class SavingGoalEntity {
  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final bool isCompleted;
  final double completionPercentage;
  final DateTime createdAt;

  const SavingGoalEntity({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.isCompleted,
    required this.completionPercentage,
    required this.createdAt,
  });
}
