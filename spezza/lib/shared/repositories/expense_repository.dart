import 'package:spezza/model/dto/expense.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spezza/shared/supabase_config/supabase_provider.dart';

part 'expense_repository.g.dart';

class ExpenseRepository {
  final SupabaseClient _supabase;

  ExpenseRepository(this._supabase);

  Future<List<Expense>> fetchExpenses() async {
    final List<Map<String, dynamic>> results = await _supabase
        .from('expenses')
        .select();

    return results.map((map) => Expense.fromMap(map)).toList();
  }

  Future<void> updateExpense(Expense expense) async {
    await _supabase
        .from('expenses')
        .update(expense.toMap())
        .eq('id', expense.id!);
  }

  Future<void> deleteExpense(int id) async {
    await _supabase
        .from('expenses')
        .delete()
        .eq('id', id);
  }

  Future<void> addExpense(Expense expense) async {
    await _supabase
        .from('expenses')
        .insert(expense.toMap());
  }
}

@riverpod
ExpenseRepository expenseRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return ExpenseRepository(supabase);
}


