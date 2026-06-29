import '../../domain/entities/saving_goal_entity.dart';

class SavingGoalModel extends SavingGoalEntity {
  const SavingGoalModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    required super.currentAmount,
    required super.targetDate,
    required super.isCompleted,
    required super.completionPercentage,
    required super.createdAt,
  });

  factory SavingGoalModel.fromJson(Map<String, dynamic> json) {
    final target = (json['targetAmount'] as num?)?.toDouble() ?? 0.0;
    final current = (json['currentAmount'] as num?)?.toDouble() ?? 0.0;
    double rawPct = target == 0 ? 0.0 : (current / target) * 100;
    if (rawPct.isNaN || rawPct.isInfinite) rawPct = 0.0;
    final double pct = rawPct.clamp(0.0, 100.0);

    return SavingGoalModel(
      id: json['id'] as int,
      name: json['name'] as String,
      targetAmount: target,
      currentAmount: current,
      targetDate: DateTime.parse(json['targetDate'] as String),
      isCompleted: pct >= 100.0,
      completionPercentage: pct,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
