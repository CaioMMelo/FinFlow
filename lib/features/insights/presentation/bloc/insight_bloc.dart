import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_insights.dart';
import 'insight_event.dart';
import 'insight_state.dart';

class InsightBloc extends Bloc<InsightEvent, InsightState> {
  final GetFinancialInsights getFinancialInsights;

  InsightBloc({required this.getFinancialInsights}) : super(const InsightInitial()) {
    on<LoadInsightsEvent>(_onLoadInsights);
  }

  Future<void> _onLoadInsights(
    LoadInsightsEvent event,
    Emitter<InsightState> emit,
  ) async {
    emit(const InsightLoading());
    final result = await getFinancialInsights(const NoParams());

    result.fold(
      (failure) => emit(InsightError(failure.message)),
      (insights) => emit(InsightLoaded(insights)),
    );
  }
}

