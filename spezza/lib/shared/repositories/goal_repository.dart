import 'package:spezza/model/dto/goal_expense.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spezza/shared/supabase_config/supabase_provider.dart';

part 'goal_repository.g.dart';

class GoalRepository {
  final SupabaseClient _supabase;

  GoalRepository(this._supabase);

  Future<List<GoalExpense>> fetchGoals() async {
    final results = await _supabase
        .from('budgetgoals')
        .select('''
        *,
        expenses:expenses!budgetgoal_id (
          id,
          budgetgoal_id,
          value,
          created_at,
          when_spent,
          category,
          name
        )
      ''');

    return results
        .map<GoalExpense>(
          (map) => GoalExpense.fromMap(map),
    )
        .toList();
  }

  Future<void> addGoal(GoalExpense goal) async {
    await _supabase
        .from('budgetgoals')
        .insert(goal.toMap());
  }

  Future<void> updateGoal(GoalExpense goal) async {
    await _supabase
        .from('budgetgoals')
        .update(goal.toMap())
        .eq('id', goal.id!);
  }

  Future<void> deleteGoal(int id) async {
    await _supabase
        .from('budgetgoals')
        .delete()
        .eq('id', id);
  }
}

@riverpod
GoalRepository goalRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return GoalRepository(supabase);
}
