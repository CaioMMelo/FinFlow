import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/pdf_report_service.dart';
import '../../../budgets/presentation/bloc/budget_bloc.dart';
import '../../../budgets/presentation/bloc/budget_state.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_state.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../budgets/domain/entities/budget_entity.dart';
import '../../domain/entities/insight_entity.dart';
import '../bloc/insight_bloc.dart';
import '../bloc/insight_event.dart';
import '../bloc/insight_state.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  Future<void> _exportPdfReport(BuildContext context) async {
    final txState = context.read<TransactionBloc>().state;
    final budgetState = context.read<BudgetBloc>().state;

    final transactions = txState is TransactionLoaded ? txState.transactions : <TransactionEntity>[];
    final budgets = budgetState is BudgetLoaded ? budgetState.budgets : <BudgetEntity>[];
    final income = txState is TransactionLoaded ? txState.totalIncomeInCents : 0;
    final expense = txState is TransactionLoaded ? txState.totalExpenseInCents : 0;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compilando relatório em PDF vetorial...'),
        duration: Duration(seconds: 1),
      ),
    );

    final pdfService = sl<PdfReportService>();
    final bytes = await pdfService.generateMonthlyReportPdf(
      transactions: transactions.cast(),
      budgets: budgets.cast(),
      totalIncomeInCents: income,
      totalExpenseInCents: expense,
      periodName: 'Mês Vigente',
    );

    await pdfService.previewOrPrintPdf(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights & Diagnóstico'),
        actions: [
          IconButton(
            tooltip: 'Exportar Relatório PDF',
            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.secondary),
            onPressed: () => _exportPdfReport(context),
          ),
          IconButton(
            tooltip: 'Atualizar Diagnóstico',
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
            onPressed: () => context.read<InsightBloc>().add(const LoadInsightsEvent()),
          ),
        ],
      ),
      body: BlocBuilder<InsightBloc, InsightState>(
        builder: (context, state) {
          if (state is InsightLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InsightError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.expense, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<InsightBloc>().add(const LoadInsightsEvent()),
                    child: const Text('Recarregar'),
                  ),
                ],
              ),
            );
          }

          if (state is InsightLoaded) {
            final data = state.insights;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<InsightBloc>().add(const LoadInsightsEvent());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHealthScoreCard(data),
                  const SizedBox(height: 16),
                  _buildMonthlyBarChart(data.monthlyHistory),
                  const SizedBox(height: 16),
                  _buildKeyMetricsRow(data),
                  const SizedBox(height: 16),
                  _buildSmartAdviceCard(data.smartAdvice),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHealthScoreCard(FinancialInsightEntity data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: data.healthScore / 100.0,
                  backgroundColor: AppColors.surfaceVariant,
                  color: AppColors.primary,
                  strokeWidth: 8,
                ),
                Center(
                  child: Text(
                    '${data.healthScore}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'SAÚDE EXCELENTE',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Score de Saúde Financeira',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Você poupou ${data.savingsRatePercentage.toStringAsFixed(1)}% da sua receita este mês.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBarChart(List<MonthlyComparison> history) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evolução Mês a Mês',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  CircleAvatar(radius: 4, backgroundColor: AppColors.income),
                  SizedBox(width: 4),
                  Text('Entradas', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  SizedBox(width: 10),
                  CircleAvatar(radius: 4, backgroundColor: AppColors.expense),
                  SizedBox(width: 4),
                  Text('Saídas', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 3000,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < history.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              history[index].monthLabel,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value ~/ 1000}k',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: history.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: item.formattedIncome,
                        color: AppColors.income,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: item.formattedExpense,
                        color: AppColors.expense,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsRow(FinancialInsightEntity data) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.savings_outlined, color: AppColors.primary, size: 18),
                    SizedBox(width: 6),
                    Text('Taxa Poupança', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${data.savingsRatePercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_down_rounded, color: AppColors.warning, size: 18),
                    SizedBox(width: 6),
                    Text('Maior Despesa', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _currencyFormat.format(data.topExpenseAmountInCents / 100.0),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  data.topExpenseCategory,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartAdviceCard(String advice) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.secondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Insight Inteligente',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

