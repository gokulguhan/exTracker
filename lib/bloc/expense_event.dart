// Events
import '../models/expense.dart';

abstract class ExpenseEvent {}

class LoadExpenses extends ExpenseEvent {}

class AddExpense extends ExpenseEvent {
  final Expense expense;
  AddExpense(this.expense);
}

class DeleteExpense extends ExpenseEvent {
  final Expense expense;
  DeleteExpense(this.expense);
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;
  UpdateExpense(this.expense);
}
