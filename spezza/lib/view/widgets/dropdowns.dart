import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryDropDown extends StatelessWidget {
  final Function(String) onSelect;
  final List<String> categories;

  const CategoryDropDown({
    super.key,
    required this.onSelect,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return ConstrainedBox(
          constraints: BoxConstraints(minWidth: 0, maxWidth: maxWidth),
          child: IntrinsicWidth(
            child: DropdownMenu(
              selectedTrailingIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.expand_less,
                  size: 20,
                  color: const Color(0xFF83814C),
                ),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF83814C),
              ),
              menuStyle: MenuStyle(
                maximumSize: WidgetStatePropertyAll(Size(maxWidth, 260)),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                isCollapsed: true,
                isDense: true,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                suffixIconConstraints: BoxConstraints.tight(Size(28, 20)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF83814C),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFDFF8D5),
                    width: 2,
                  ),
                ),
                suffixIconColor: Colors.white,
              ),
              trailingIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.expand_more,
                  size: 20,
                  color: const Color(0xFF83814C),
                ),
              ),
              onSelected: (String? value) {
                if (value != null) onSelect(value);
              },
              initialSelection: categories[0],
              dropdownMenuEntries: categories
                  .map((entry) => DropdownMenuEntry(value: entry, label: entry))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class GraphicOverviewPeriodDropdown extends StatefulWidget {
  final Function(GraphicOverviewPeriod, DateTime?, DateTime?) onSelect;

  const GraphicOverviewPeriodDropdown({super.key, required this.onSelect});

  @override
  State<GraphicOverviewPeriodDropdown> createState() =>
      _GraphicOverviewPeriodDropdownState();
}

class _GraphicOverviewPeriodDropdownState
    extends State<GraphicOverviewPeriodDropdown> {
  final controller = TextEditingController();

  String getFormattedDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yy');
    return formatter.format(date);
  }

  Future<DateTime?> pickDate(String helper, {DateTime? initialDate}) async {
    return await showDatePicker(
      helpText: helper,
      context: context,
      initialDate: DateTime.now(),
      firstDate: initialDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      selectedTrailingIcon: Padding(
        padding: EdgeInsets.only(right: 8),
        child: Icon(Icons.expand_less, size: 20, color: Color(0xFF008000)),
      ),
      width: 200,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF008000),
      ),
      controller: controller,
      menuStyle: MenuStyle(
        fixedSize: const WidgetStatePropertyAll(Size(200, 260)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isCollapsed: true,
        isDense: true,
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        suffixIconConstraints: BoxConstraints.tight(Size(28, 20)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF008000), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF008000), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF008000), width: 2),
        ),
        suffixIconColor: Colors.white,
      ),
      trailingIcon: Padding(
        padding: EdgeInsets.only(right: 8),
        child: Icon(Icons.expand_more, size: 20, color: Color(0xFF008000)),
      ),
      onSelected: (GraphicOverviewPeriod? value) async {
        DateTime? start, end;
        if (value == GraphicOverviewPeriod.specificPeriod) {
          start = await pickDate('Selecione a data inicial');
          if (start != null) {
            end = await pickDate('Selecione a data final', initialDate: start);
          }
          if (start == null || end == null) {
            value = GraphicOverviewPeriod.lastWeek;
            controller.text = GraphicOverviewPeriod.lastWeek.text;
          } else {
            controller.text =
                '${getFormattedDate(start)} a ${getFormattedDate(end)}';
          }
        }
        widget.onSelect(value!, start, end);
      },
      initialSelection: GraphicOverviewPeriod.lastWeek,

      dropdownMenuEntries: GraphicOverviewPeriod.values.map((entry) {
        return DropdownMenuEntry(value: entry, label: entry.text);
      }).toList(),
    );
  }
}

enum GraphicOverviewPeriod {
  lastWeek('Última semana'),
  lastMonth('Último mês'),
  lastSixMonths('Último semestre'),
  lastYear('Último ano'),
  specificPeriod('Selecionar período...');

  const GraphicOverviewPeriod(this.text);

  final String text;
}
