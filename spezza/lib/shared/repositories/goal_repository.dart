import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spezza/model/dto/goal_expense.dart';
import 'package:spezza/shared/supabase_config/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'goal_repository.g.dart';

class GoalRepository {
  final SupabaseClient _supabase;

  GoalRepository(this._supabase);

  Future<void> deleteGoal(int id) async {
    await _supabase.from('budgetgoals').delete().eq('id', id);
  }

  Future<void> updateGoal(int id, Map<String, dynamic> changes) async {
    await _supabase.from('budgetgoals').update(changes).eq('id', id);
  }

  Future<dynamic> addGoal(Map<String, dynamic> payload) async {
    final res = await _supabase.from('budgetgoals').insert(payload).select();
    // `res` may be a PostgrestList at runtime; suppress unnecessary_type_check warning
    // ignore: unnecessary_type_check
    if (res is List && res.isNotEmpty) return res.first;
    if (res is Map) return res;
    return null;
  }

  Future<List<GoalExpense>> fetchGoals() async {
    final results = await _supabase.from('budgetgoals').select('''
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

    return results.map<GoalExpense>((map) => GoalExpense.fromMap(map)).toList();
  }
}

@riverpod
GoalRepository goalRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return GoalRepository(supabase);
}
