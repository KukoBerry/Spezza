import 'package:flutter/material.dart';

import '../../model/dto/goal_expense.dart';

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
  DateTime? _parseCreatedAt(Map<String, dynamic> map) {
    final raw = map['created_at'] ?? map['createdAt'];
    if (raw == null) return null;
    if (raw is DateTime) return raw.toLocal();
    try {
      return DateTime.parse(raw.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  double? _parseGoal(Map<String, dynamic> map) {
    final raw = map['goalexpense'] ?? map['goal'] ?? map['goalExpense'];
    if (raw == null) return null;
    return (raw as num).toDouble();
  }

  double? _parseAmount(Map<String, dynamic> map) {
    final raw = map['expense'] ?? map['amountSpent'] ?? map['amount_spent'];
    if (raw == null) return null;
    return (raw as num).toDouble();
  }

  int? _parseDays(Map<String, dynamic> map) {
    final raw =
        map['daysperiod'] ??
        map['days_period'] ??
        map['periodInDays'] ??
        map['period_in_days'];
    if (raw == null) return null;
    return (raw is int) ? raw : int.tryParse(raw.toString());
  }

  String? _parseString(Map<String, dynamic> map, String key) {
    final raw = map[key] ?? map[key.toLowerCase()];
    if (raw == null) return null;
    return raw.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Collect source map
    final Map<String, dynamic> src = {};
    if (widget.goal != null) {
      src['created_at'] = widget.goal!.createdAt;
      src['goalexpense'] = widget.goal!.goal;
      src['daysperiod'] = widget.goal!.periodInDays;
      src['category'] = widget.goal!.category;
      src['name'] = widget.goal!.name;
    } else if (widget.data != null) {
      src.addAll(widget.data!);
    }

    final createdAt = widget.goal?.createdAt ?? _parseCreatedAt(src);
    final goalAmount = widget.goal?.goal ?? _parseGoal(src);
    final amountSpent = widget.goal?.amountSpent ?? _parseAmount(src) ?? 0.0;
    final days = widget.goal?.periodInDays ?? _parseDays(src) ?? 0;
    final category =
        widget.goal?.category ?? _parseString(src, 'category') ?? '-';
    final name = widget.goal?.name ?? _parseString(src, 'name') ?? '-';

    // Build UI to match provided design: rounded green card, date range and percent on top,
    // a two-color progress bar (spent = red, remaining = green), amounts centered, and category below.
    final bg = const Color.fromRGBO(13, 170, 24, 1);

    // calculate dates
    final start = createdAt;
    final end = (createdAt != null)
        ? createdAt.add(Duration(days: days))
        : null;

    final spent = amountSpent;
    final goal = goalAmount ?? 0.0;
    final percent = (goal > 0) ? (spent / goal).clamp(0.0, 1.0) : 0.0;

    String formatShortDate(DateTime d) =>
        '${d.day}/${d.month}/${d.year.toString().substring(2)}';

    String formatMoney(double v) {
      // simple formatter: two decimals and comma as decimal separator
      final s = v.toStringAsFixed(2);
      return s.replaceAll('.', ',');
    }

    return Container(
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
                  (start == null || end == null)
                      ? '-'
                      : '${formatShortDate(start)} - ${formatShortDate(end)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              Text(
                '${(percent * 100).round()}%',
                style: const TextStyle(color: Colors.white, fontSize: 12),
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
    );
  }
}

// _InfoTile removed — layout refactored to match design
