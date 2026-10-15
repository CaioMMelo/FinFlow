import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/budget_entity.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  int _touchedSectionIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamento & Metas (50/30/20)'),
        actions: [
          IconButton(
            tooltip: 'Recarregar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<BudgetBloc>().add(const LoadBudgetsEvent()),
          ),
        ],
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BudgetError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.expense, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<BudgetBloc>().add(const LoadBudgetsEvent()),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is BudgetLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<BudgetBloc>().add(const LoadBudgetsEvent());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildChartCard(state),
                  const SizedBox(height: 24),
                  const Text(
                    'Categorias e Alocações',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...state.budgets.map((b) => _buildBudgetItemCard(b)),
                  const SizedBox(height: 64),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: Semantics(
        label: 'Criar novo orçamento ou meta financeira',
        button: true,
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.secondary,
          icon: const Icon(Icons.add_chart_rounded, color: Colors.white),
          label: const Text('Nova Meta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () => _showAddBudgetBottomSheet(context),
        ),
      ),
    );
  }

  Widget _buildChartCard(BudgetLoaded state) {
    final needsSpent = state.totalSpentNeedsInCents / 100.0;
    final wantsSpent = state.totalSpentWantsInCents / 100.0;
    final savingsSpent = state.totalSpentSavingsInCents / 100.0;
    final totalSpent = needsSpent + wantsSpent + savingsSpent;

    return Semantics(
      label: 'Gráfico da regra 50/30/20. Total executado: ${_currencyFormat.format(totalSpent)}',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.pie_chart_outline_rounded, color: AppColors.secondary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Distribuição Real dos Gastos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: totalSpent == 0
                  ? const Center(child: Text('Nenhum gasto orçado registrado.'))
                  : PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedSectionIndex = -1;
                                return;
                              }
                              _touchedSectionIndex =
                                  pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 4,
                        centerSpaceRadius: 46,
                        sections: [
                          PieChartSectionData(
                            color: AppColors.primary,
                            value: needsSpent,
                            title: '${((needsSpent / totalSpent) * 100).toStringAsFixed(0)}%',
                            radius: _touchedSectionIndex == 0 ? 38 : 32,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          PieChartSectionData(
                            color: AppColors.secondary,
                            value: wantsSpent,
                            title: '${((wantsSpent / totalSpent) * 100).toStringAsFixed(0)}%',
                            radius: _touchedSectionIndex == 1 ? 38 : 32,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: AppColors.warning,
                            value: savingsSpent,
                            title: '${((savingsSpent / totalSpent) * 100).toStringAsFixed(0)}%',
                            radius: _touchedSectionIndex == 2 ? 38 : 32,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('50% Necessidades', AppColors.primary),
                _buildLegendItem('30% Desejos', AppColors.secondary),
                _buildLegendItem('20% Metas', AppColors.warning),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildBudgetItemCard(BudgetEntity b) {
    final progress = b.progressPercentage;
    final color = b.isExceeded
        ? AppColors.expense
        : b.categoryGroup == BudgetCategoryGroup.needs
            ? AppColors.primary
            : b.categoryGroup == BudgetCategoryGroup.wants
                ? AppColors.secondary
                : AppColors.warning;

    return Semantics(
      label: '${b.name}, teto ${_currencyFormat.format(b.formattedTarget)}, atual ${_currencyFormat.format(b.formattedCurrent)}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      b.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      b.categoryGroup.label,
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppColors.surfaceVariant,
                color: color,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currencyFormat.format(b.formattedCurrent)} gastos',
                    style: TextStyle(
                      color: b.isExceeded ? AppColors.expense : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: b.isExceeded ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    'Teto: ${_currencyFormat.format(b.formattedTarget)} (${(progress * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBudgetBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    BudgetCategoryGroup selectedGroup = BudgetCategoryGroup.needs;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Criar Novo Orçamento ou Meta',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Meta / Orçamento',
                      hintText: 'Ex: Supermercado, Aluguel, Reserva',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Teto / Meta em Reais (R\$)',
                      hintText: 'Ex: 1000.00',
                      prefixText: 'R\$ ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Grupo da Regra 50/30/20:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<BudgetCategoryGroup>(
                    initialValue: selectedGroup,
                    dropdownColor: AppColors.surface,
                    items: BudgetCategoryGroup.values.map((group) {
                      return DropdownMenuItem(
                        value: group,
                        child: Text(group.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedGroup = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        final rawAmount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;
                        final amountInCents = (rawAmount * 100).round();

                        if (name.isNotEmpty && amountInCents > 0) {
                          final newBudget = BudgetEntity(
                            id: const Uuid().v4(),
                            name: name,
                            targetAmountInCents: amountInCents,
                            currentAmountInCents: 0,
                            categoryGroup: selectedGroup,
                          );

                          this.context.read<BudgetBloc>().add(CreateBudgetEvent(newBudget));
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Salvar Orçamento', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

