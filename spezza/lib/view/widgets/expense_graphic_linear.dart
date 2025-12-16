import 'package:flutter/material.dart';
import 'package:spezza/shared/utils/graphic_colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:spezza/view_model/graphic_overview_view_model.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class ExpenseGraphicLinear extends StatelessWidget {
  final Map<String, List<ChartData>> expenses;

  const ExpenseGraphicLinear({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black54;
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(color: textColor),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 1),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      primaryYAxis: NumericAxis(
        isVisible: false,
        majorGridLines: const MajorGridLines(width: 0),
        minorGridLines: const MinorGridLines(width: 0),
      ),
      legend: Legend(
        isVisible: true,
        textStyle: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: expenses.entries.toList().asMap().entries.map((entry) {
        final index = entry.key;
        final seriesEntry = entry.value;

        final seriesName = seriesEntry.key;
        final data = seriesEntry.value;

        final color = colors[index % colors.length];

        return LineSeries<ChartData, String>(
          name: seriesName,
          dataSource: data,
          color: color,
          xValueMapper: (ChartData d, _) => d.x,
          yValueMapper: (ChartData d, _) => d.y,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          markerSettings: const MarkerSettings(isVisible: true),
        );
      }).toList(),
    );
  }
}
