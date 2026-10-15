import '../../domain/entities/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.name,
    required super.targetAmountInCents,
    super.currentAmountInCents,
    required super.categoryGroup,
    super.deadline,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmountInCents: json['targetAmountInCents'] as int,
      currentAmountInCents: json['currentAmountInCents'] as int? ?? 0,
      categoryGroup: BudgetCategoryGroup.values.firstWhere(
        (e) => e.name == json['categoryGroup'],
        orElse: () => BudgetCategoryGroup.needs,
      ),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmountInCents': targetAmountInCents,
      'currentAmountInCents': currentAmountInCents,
      'categoryGroup': categoryGroup.name,
      'deadline': deadline?.toIso8601String(),
    };
  }

  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      name: entity.name,
      targetAmountInCents: entity.targetAmountInCents,
      currentAmountInCents: entity.currentAmountInCents,
      categoryGroup: entity.categoryGroup,
      deadline: entity.deadline,
    );
  }
}

