import 'package:get_it/get_it.dart';
import '../database/app_database.dart';
import '../security/biometric_service.dart';
import '../security/device_security_service.dart';
import '../security/secure_storage_service.dart';
import '../services/pdf_report_service.dart';

import '../../features/transactions/data/datasources/transaction_local_datasource.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/add_transaction.dart';
import '../../features/transactions/domain/usecases/get_transactions.dart';
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';

import '../../features/budgets/data/datasources/budget_local_datasource.dart';
import '../../features/budgets/data/repositories/budget_repository_impl.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/budgets/domain/usecases/create_budget.dart';
import '../../features/budgets/domain/usecases/get_budgets.dart';
import '../../features/budgets/presentation/bloc/budget_bloc.dart';

import '../../features/insights/data/datasources/insight_local_datasource.dart';
import '../../features/insights/data/repositories/insight_repository_impl.dart';
import '../../features/insights/domain/repositories/insight_repository.dart';
import '../../features/insights/domain/usecases/get_insights.dart';
import '../../features/insights/presentation/bloc/insight_bloc.dart';

import '../../features/receipts/domain/services/receipt_scanner_service.dart';
import '../../features/receipts/data/services/receipt_ocr_service_impl.dart';

import '../../features/ai_assistant/domain/repositories/ai_assistant_repository.dart';
import '../../features/ai_assistant/domain/usecases/send_ai_message.dart';
import '../../features/ai_assistant/data/datasources/gemini_ai_remote_datasource.dart';
import '../../features/ai_assistant/data/repositories/ai_assistant_repository_impl.dart';
import '../../features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  //! Core / Security & Persistence (Singletons)
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<BiometricService>(() => BiometricService());
  sl.registerLazySingleton<DeviceSecurityService>(() => DeviceSecurityService());
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase(secureStorage: sl()));
  sl.registerLazySingleton<PdfReportService>(() => PdfReportService());
  sl.registerLazySingleton<ReceiptScannerService>(() => ReceiptOcrServiceImpl());

  //! Feature 1 - Transactions
  sl.registerFactory(
    () => TransactionBloc(
      getTransactions: sl(),
      addTransaction: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => InMemoryTransactionLocalDataSource(),
  );

  //! Feature 2 - Budgets (50/30/20)
  sl.registerFactory(
    () => BudgetBloc(
      getBudgets: sl(),
      createBudget: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetBudgets(sl()));
  sl.registerLazySingleton(() => CreateBudget(sl()));
  sl.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<BudgetLocalDataSource>(
    () => InMemoryBudgetLocalDataSource(),
  );

  //! Feature 3 - Insights
  sl.registerFactory(() => InsightBloc(getFinancialInsights: sl()));
  sl.registerLazySingleton(() => GetFinancialInsights(sl()));
  sl.registerLazySingleton<InsightRepository>(
    () => InsightRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<InsightLocalDataSource>(
    () => InMemoryInsightLocalDataSource(),
  );

  //! Feature 4 - AI Assistant (Google Gemini)
  sl.registerFactory(
    () => AiAssistantBloc(
      sendAiMessage: sl(),
      repository: sl(),
    ),
  );
  sl.registerLazySingleton(() => SendAiMessage(sl()));
  sl.registerLazySingleton<AiAssistantRepository>(
    () => AiAssistantRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GeminiAiRemoteDataSource>(
    () => GeminiAiRemoteDataSourceImpl(
      secureStorage: sl(),
      addTransactionUseCase: sl(),
      getTransactionsUseCase: sl(),
    ),
  );
}
