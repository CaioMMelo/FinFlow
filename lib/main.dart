import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';
import 'features/auth/presentation/pages/auth_security_gate_page.dart';
import 'features/budgets/presentation/bloc/budget_bloc.dart';
import 'features/budgets/presentation/bloc/budget_event.dart';
import 'features/insights/presentation/bloc/insight_bloc.dart';
import 'features/insights/presentation/bloc/insight_event.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o container de Injeção de Dependências (Service Locator)
  await di.initServiceLocator();

  runApp(const FinFlowApp());
}

class FinFlowApp extends StatelessWidget {
  const FinFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>(
          create: (_) => di.sl<TransactionBloc>()..add(const LoadTransactionsEvent()),
        ),
        BlocProvider<BudgetBloc>(
          create: (_) => di.sl<BudgetBloc>()..add(const LoadBudgetsEvent()),
        ),
        BlocProvider<InsightBloc>(
          create: (_) => di.sl<InsightBloc>()..add(const LoadInsightsEvent()),
        ),
        BlocProvider<AiAssistantBloc>(
          create: (_) => di.sl<AiAssistantBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'FinFlow - Gestão Financeira',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthSecurityGatePage(),
      ),
    );
  }
}
