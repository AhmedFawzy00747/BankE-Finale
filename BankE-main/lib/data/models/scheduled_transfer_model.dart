import '../../domain/entities/scheduled_transfer_entity.dart';

class ScheduledTransferModel extends ScheduledTransferEntity {
  const ScheduledTransferModel({
    required super.id,
    required super.receiverAccountNumber,
    required super.amount,
    super.description,
    required super.scheduledDate,
    required super.frequency,
    required super.isActive,
    required super.createdAt,
    super.lastExecutedAt,
    required super.nextExecutionDate,
  });

  factory ScheduledTransferModel.fromJson(Map<String, dynamic> json) {
    return ScheduledTransferModel(
      id: json['id'] as int,
      receiverAccountNumber: json['receiverAccountNumber'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      frequency: json['frequency'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastExecutedAt: json['lastExecutedAt'] != null
          ? DateTime.parse(json['lastExecutedAt'] as String)
          : null,
      nextExecutionDate: DateTime.parse(json['nextExecutionDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiverAccountNumber': receiverAccountNumber,
      'amount': amount,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'frequency': frequency,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastExecutedAt': lastExecutedAt?.toIso8601String(),
      'nextExecutionDate': nextExecutionDate.toIso8601String(),
    };
  }
}
