import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/budgets/domain/entities/budget_entity.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';

/// Serviço responsável pela geração de relatórios e extratos financeiros mensais em formato PDF vetorial.
///
/// **Relevância Técnica:**
/// O pacote `pdf` compila um documento PDF nativo diretamente em memória usando canvas vetorial (sem depender de WebView),
/// garantindo fidelidade de impressão, baixo consumo de memória e total funcionamento 100% offline.
class PdfReportService {
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _dateFormat = DateFormat('dd/MM/yyyy');

  /// Gera os bytes do documento PDF do extrato mensal
  Future<Uint8List> generateMonthlyReportPdf({
    required List<TransactionEntity> transactions,
    required List<BudgetEntity> budgets,
    required int totalIncomeInCents,
    required int totalExpenseInCents,
    String periodName = 'Mês Atual',
  }) async {
    final pdf = pw.Document();
    final balanceInCents = totalIncomeInCents - totalExpenseInCents;
    final nowFormatted = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) => _buildPdfHeader(periodName),
        footer: (pw.Context context) => _buildPdfFooter(context, nowFormatted),
        build: (pw.Context context) => [
          _buildSummaryCards(
            balanceInCents: balanceInCents,
            totalIncomeInCents: totalIncomeInCents,
            totalExpenseInCents: totalExpenseInCents,
          ),
          pw.SizedBox(height: 20),
          _buildBudgetSection(budgets),
          pw.SizedBox(height: 20),
          _buildTransactionsTable(transactions),
        ],
      ),
    );

    return await pdf.save();
  }

  /// Dispara a tela nativa de impressão ou visualização de PDF
  Future<void> previewOrPrintPdf(Uint8List pdfBytes, {String title = 'Relatório Financeiro - FinFlow'}) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
    );
  }

  /// Compartilha o arquivo PDF gerado via WhatsApp, e-mail ou armazenamento do celular
  Future<void> sharePdf(Uint8List pdfBytes, {String filename = 'extrato_finflow.pdf'}) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }

  pw.Widget _buildPdfHeader(String periodName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'FinFlow - Gestão Financeira Pessoal',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Relatório Consolidado de Movimentações & Orçamento ($periodName)',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey700),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: pw.BoxDecoration(
                color: PdfColors.teal50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.teal300, width: 1),
              ),
              child: pw.Text(
                'EXTRATO OFICIAL',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal900,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 12),
      ],
    );
  }

  pw.Widget _buildSummaryCards({
    required int balanceInCents,
    required int totalIncomeInCents,
    required int totalExpenseInCents,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            title: 'SALDO LÍQUIDO',
            amount: balanceInCents,
            color: balanceInCents >= 0 ? PdfColors.teal700 : PdfColors.red700,
          ),
          _buildSummaryItem(
            title: 'TOTAL RECEITAS',
            amount: totalIncomeInCents,
            color: PdfColors.green700,
          ),
          _buildSummaryItem(
            title: 'TOTAL DESPESAS',
            amount: totalExpenseInCents,
            color: PdfColors.red700,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem({
    required String title,
    required int amount,
    required PdfColor color,
  }) {
    final formatted = _currencyFormat.format(amount / 100.0);
    return pw.Column(
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          formatted,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildBudgetSection(List<BudgetEntity> budgets) {
    if (budgets.isEmpty) return pw.SizedBox.shrink();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Metas & Orçamentos (Regra 50/30/20)',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellStyle: const pw.TextStyle(fontSize: 8),
          headers: ['Meta / Grupo', 'Alocação Planejada', 'Gasto Realizado', 'Progresso'],
          data: budgets.map((b) {
            final progress = (b.progressPercentage * 100).toStringAsFixed(0);
            return [
              '${b.name} (${b.categoryGroup.label})',
              _currencyFormat.format(b.formattedTarget),
              _currencyFormat.format(b.formattedCurrent),
              '$progress%',
            ];
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildTransactionsTable(List<TransactionEntity> transactions) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detalhamento das Movimentações Financeiras',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellStyle: const pw.TextStyle(fontSize: 8),
          headers: ['Data', 'Descrição / Título', 'Categoria', 'Tipo', 'Valor'],
          data: transactions.map((t) {
            final isIncome = t.type == TransactionType.income;
            final prefix = isIncome ? '+' : '-';
            final valueStr = '$prefix ${_currencyFormat.format(t.formattedAmount)}';
            return [
              _dateFormat.format(t.date),
              t.title,
              t.category.name,
              isIncome ? 'Receita' : 'Despesa',
              valueStr,
            ];
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context, String generationDate) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Gerado via FinFlow Mobile • Criptografia de Hardware em Repouso',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
            pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount} • Emissão: $generationDate',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }
}

