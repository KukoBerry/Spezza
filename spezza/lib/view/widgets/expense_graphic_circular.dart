import 'package:flutter/material.dart';
import 'package:spezza/view_model/graphic_overview_view_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:spezza/shared/utils/graphic_colors.dart';

class ExpenseGraphicCircular extends StatefulWidget {
  final List<ChartData> totalExpensesByCategory;

  const ExpenseGraphicCircular({
    super.key,
    required this.totalExpensesByCategory,
  });

  @override
  State<ExpenseGraphicCircular> createState() => _ExpenseGraphicCircularState();
}

class _ExpenseGraphicCircularState extends State<ExpenseGraphicCircular> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white70 : Colors.black26;
    final textColor = isDark ? Colors.white70 : Colors.black54;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(width: 0.7, color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Gastos por categoria',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
             Text(
              'Top 10 categorias',
              style: TextStyle(fontSize: 12, color: textColor),
            ),
            const SizedBox(height: 16),
            Center(
              child: SfCircularChart(
                legend: Legend(isVisible: true),
                series: <PieSeries<ChartData, String>>[
                  PieSeries<ChartData, String>(
                    onPointTap: (ChartPointDetails details) {
                      setState(() {
                        _selectedIndex =
                        _selectedIndex == details.pointIndex ? null : details.pointIndex;
                      });
                    },
                    pointColorMapper: (ChartData data, int index) {
                      return colors[index % colors.length];
                    },
                    explode: true,
                    explodeIndex: _selectedIndex,
                    dataSource: widget.totalExpensesByCategory,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    dataLabelMapper: (data, index) =>
                        index == _selectedIndex ? data.text : null,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
