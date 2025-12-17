import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/dto/goal_expense.dart';
import '../screens/expenses_list_view.dart';
import './delete_goal_button.dart';
import 'edit_goal_button.dart';

/// Widget that displays information about a goal expense.
///
/// Example usage:
/// ```dart
/// GoalExpenseInfo(goal: myGoalExpense)
/// // or
/// GoalExpenseInfo(data: myMapFromApi)
/// ```
class BudgetGoalInfo extends StatefulWidget {
  final GoalExpense? goal;
  final Map<String, dynamic>? data;

  const BudgetGoalInfo({super.key, this.goal, this.data})
    : assert(
        goal != null || data != null,
        'Provide either a GoalExpense object or a Map<String, dynamic>',
      );

  @override
  State<BudgetGoalInfo> createState() => _BudgetGoalInfoState();
}

class _BudgetGoalInfoState extends State<BudgetGoalInfo> {
  bool _isDeleted = false;
  double? _remoteSpent;
  bool _loadingRemoteSpent = false;
  // Local editable state so UI updates immediately after editing
  double? _localGoal;
  String? _localCategory;
  String? _localName;

  @override
  void initState() {
    super.initState();
    _initRemoteSpent();
  }

  void _initRemoteSpent() {
    final idVal = widget.goal?.id ?? widget.data?['id'];
    int? idInt;
    idInt = idVal;

    // initialize local display values from provided data
    final src = widget.data!;
    final parsedGoal = src['goalexpense'] ?? src['goal'];
    _localGoal = (parsedGoal as num).toDouble();
    _localCategory = src['category']?.toString();
    _localName = src['name']?.toString();
    if (idInt != null) _fetchRemoteSpent(idInt);
  }

  Future<void> _fetchRemoteSpent(int id) async {
    setState(() => _loadingRemoteSpent = true);
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('expenses')
          .select('value')
          .eq('budgetgoal_id', id);
      double sum = 0.0;
      for (final e in res) {
        if (e['value'] != null) {
          try {
            sum += (e['value'] as num).toDouble();
          } catch (_) {}
        }
      }
      if (!mounted) return;
      setState(() {
        _remoteSpent = sum;
        _loadingRemoteSpent = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingRemoteSpent = false);
    }
  }

  DateTime? _parseCreatedAt(Map<String, dynamic> map) {
    final raw = map['created_at'];
    return DateTime.parse(raw.toString()).toLocal();
  }

  double? _parseGoal(Map<String, dynamic> map) {
    final raw = map['goalexpense'];
    return (raw as num).toDouble();
  }

  int? _parseDays(Map<String, dynamic> map) {
    final raw = map['daysperiod'];
    return (raw is int) ? raw : int.tryParse(raw.toString());
  }

  String? _parseString(Map<String, dynamic> map, String key) {
    final raw = map[key];
    return raw.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Collect source map
    final Map<String, dynamic> src = {};

    src.addAll(widget.data!);

    final createdAt = _parseCreatedAt(src);
    final goalAmount = _parseGoal(src);
    final days = _parseDays(src) ?? 0;
    final category = _localCategory ?? _parseString(src, 'category') ?? '-';
    final name = _localName ?? _parseString(src, 'name') ?? '-';

    final idVal = src['id'];
    int? idInt;
    if (idVal is int) {
      idInt = idVal;
    } else {
      idInt = int.tryParse(idVal?.toString() ?? '');
    }

    // Build UI to match provided design: rounded green card, date range and percent on top,
    // a two-color progress bar (spent = red, remaining = green), amounts centered, and category below.
    final bg = const Color.fromRGBO(13, 170, 24, 1);

    // calculate dates
    final start = createdAt;
    final end = createdAt!.add(Duration(days: days));

    // compute local fallback spent from embedded expenses if present

    final spent = _remoteSpent ?? 0.0;
    final goal = _localGoal ?? (goalAmount ?? 0.0);
    final percent = (goal > 0) ? (spent / goal) : 0.0;

    String formatShortDate(DateTime d) =>
        '${d.day}/${d.month}/${d.year.toString().substring(2)}';

    String formatMoney(double v) {
      // simple formatter: two decimals and comma as decimal separator
      final s = v.toStringAsFixed(2);
      return s.replaceAll('.', ',');
    }

    if (_isDeleted) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        if (idInt != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ExpensesListView(goalId: idInt!, name: name),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (name != '-')
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    (start == null)
                        ? '-'
                        : '${formatShortDate(start)} - ${formatShortDate(end)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                // percent + delete controls
                Row(
                  children: [
                    Text(
                      '${(percent * 100).round()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    EditGoalButton(
                      goalAmount: _localGoal ?? goalAmount!,
                      category: category,
                      name: name,
                      src: src,
                      onSaved: (g, c, n) {
                        setState(() {
                          _localGoal = g;
                          _localCategory = c.isEmpty ? null : c;
                          _localName = n.isEmpty ? null : n;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    if (idInt != null)
                      DeleteGoalButton(
                        id: idInt,
                        onDeleted: () {
                          if (!mounted) return;
                          setState(() {
                            _isDeleted = true;
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // progress bar: red = spent, green = remaining
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: [
                    Expanded(
                      flex: (percent * 1000).round(),
                      child: Container(color: Colors.redAccent),
                    ),
                    Expanded(
                      flex: ((1 - percent) * 1000).round(),
                      child: Container(
                        color: const Color.fromRGBO(136, 243, 255, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${formatMoney(spent)}/${formatMoney(goal)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(category, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
