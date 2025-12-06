import 'package:spezza/model/dto/goal_expense.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spezza/shared/supabase_config/supabase_provider.dart';

part 'goal_repository.g.dart';

class GoalRepository {
  final SupabaseClient _supabase;

  GoalRepository(this._supabase);

  Future<List<GoalExpense>> fetchGoals() async {
    final List<Map<String, dynamic>> results = await _supabase
        .from('budgetgoals')
        .select();

    return results.map((map) => GoalExpense.fromMap(map)).toList();
  }
}

@riverpod
GoalRepository goalRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return GoalRepository(supabase);
}
