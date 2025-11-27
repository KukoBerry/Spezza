import 'package:spezza/goal_expense.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoalRepository {
  Future<List<GoalExpense>> fetchGoals() async {
    final List<Map<String, dynamic>> results = 
    await Supabase.instance.client.from('budgetgoals').select();

    return results.map((map) => GoalExpense.fromMap(map)).toList();
  }
}