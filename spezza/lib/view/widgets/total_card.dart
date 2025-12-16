import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spezza/model/dto/expense.dart';
import 'package:spezza/model/dto/goal_expense.dart';

class TotalCard extends StatelessWidget {
  final String title;
  final dynamic values;
  final Icon icon;
  final bool? hasBorder;

  const TotalCard({
    super.key,
    required this.title,
    required this.values,
    required this.icon,
    this.hasBorder,
  });

  double get total {
    double sum = 0;

    for (var value in values) {
      if (value is GoalExpense) {
        sum += value.goal;
      } else if (value is Expense) {
        sum += value.value;
      }
    }

    return sum;
  }

  String formatValue(double value) {
    final formatter = NumberFormat('0.00', 'pt_BR');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white70 : Colors.black26;
    final textColor = isDark ? Colors.white70 : Colors.black54;

    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 0.7),
        ),
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              Padding(padding: EdgeInsets.all(8)),
              Text(title, style: TextStyle(color: textColor, fontSize: 12)),
              Padding(padding: EdgeInsets.all(2)),
              Text(
                'R\$ ${formatValue(total)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: icon.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
