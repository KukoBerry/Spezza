import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesListView extends StatefulWidget {
  final int goalId;
  final String name;

  const ExpensesListView({super.key, required this.goalId, required this.name});

  @override
  State<ExpensesListView> createState() => _ExpensesListViewState();
}

class _ExpensesListViewState extends State<ExpensesListView> {
  bool _loading = true;
  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('expenses')
          .select()
          .eq('budgetgoal_id', widget.goalId);


      if (!mounted) return;
      final list = <Map<String, dynamic>>[];
      for (final e in res) {
        list.add(Map<String, dynamic>.from(e));
      }
      setState(() {
        _expenses = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _expenses.isEmpty
          ? const Center(child: Text('Sem despesas!'))
          : ListView.separated(
              itemCount: _expenses.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final e = _expenses[index];
                final name = e['name']?.toString() ?? '-';
                final value = e['value'];
                final valueStr = (value is num)
                    ? value.toString()
                    : (value?.toString() ?? '-');
                return ListTile(title: Text(name), trailing: Text(valueStr));
              },
            ),
    );
  }
}
