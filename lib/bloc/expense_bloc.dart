import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/database_helper.dart';
import 'expense_event.dart';
import 'expense_state.dart';

// BLoC
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final DatabaseHelper dbHelper;

  ExpenseBloc({required this.dbHelper}) : super(ExpenseInitial()) {
    on<LoadExpenses>((event, emit) async {
      emit(ExpenseLoading());
      try {
        final expenses = await dbHelper
            .getExpenses(); // Make sure method name matches DatabaseHelper
        emit(ExpenseLoaded(
            expenses)); // Changed from ExpenseLoaded to ExpenseLoaded
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<AddExpense>((event, emit) async {
      emit(ExpenseLoading());
      try {
        await dbHelper.insertExpense(event.expense);
        final expenses = await dbHelper.getExpenses();
        emit(ExpenseLoaded(
            expenses)); // Changed from ExpenseLoaded to ExpenseLoaded
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<DeleteExpense>((event, emit) async {
      emit(ExpenseLoading());
      try {
        await dbHelper.deleteExpense(event.expense.id!);
        final expenses = await dbHelper.getExpenses();
        emit(ExpenseLoaded(
            expenses)); // Changed from ExpenseLoaded to ExpenseLoaded
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<UpdateExpense>((event, emit) async {
      emit(ExpenseLoading());
      try {
        await dbHelper.updateExpense(event.expense);
        final expenses = await dbHelper.getExpenses();
        emit(ExpenseLoaded(
            expenses)); // Changed from ExpenseLoaded to ExpenseLoaded
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });
  }

  // Add method to load expenses initially
  void loadExpenses() {
    add(LoadExpenses());
  }
}
