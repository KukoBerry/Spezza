import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/shared/supabase_config/supabase_credentials.dart';
import 'package:spezza/sidebar.dart';
import 'package:spezza/theme_provider.dart';
import 'package:spezza/view/widgets/budget_goal_info.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Function.apply(Supabase.initialize, [], supabaseOptions);

  final supabase = Supabase.instance.client;

  final data = await supabase.from('budgetgoals').select();

  // Ensure deterministic ordering by created_at (oldest first). If created_at is missing or unparsable,
  // those items will be placed at the end.
  data.sort((a, b) {
    dynamic va = (a['created_at'] ?? a['createdAt']);
    dynamic vb = (b['created_at'] ?? b['createdAt']);
    DateTime? da;
    DateTime? db;
    try {
      if (va != null) da = DateTime.tryParse(va.toString());
    } catch (_) {}
    try {
      if (vb != null) db = DateTime.tryParse(vb.toString());
    } catch (_) {}
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  });

  runApp(ProviderScope(child: MyApp(initialData: data)));
}

class MyApp extends ConsumerWidget {
  final List<dynamic>? initialData;

  const MyApp({super.key, this.initialData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Spezza',
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF008000),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF008000),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF008000),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF008000),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),

        drawerTheme: const DrawerThemeData(backgroundColor: Colors.black),

        listTileTheme: const ListTileThemeData(
          iconColor: Colors.white,
          textColor: Colors.white,
        ),

        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomePage(initialData: initialData),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<dynamic>? initialData;
  const HomePage({super.key, this.initialData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<dynamic> _data;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _data = (widget.initialData != null) ? List.from(widget.initialData!) : [];
  }

  Future<void> _showCreateDialog() async {
    final goalController = TextEditingController();
    final daysController = TextEditingController();
    final categoryController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Nova meta de gastos'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                ),
                TextFormField(
                  controller: goalController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Valor'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v.replaceAll(',', '.')) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: daysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Período em dias',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final parsedGoal =
                    double.tryParse(goalController.text.replaceAll(',', '.')) ??
                    0.0;
                final days = int.tryParse(daysController.text) ?? 0;
                final category = categoryController.text.trim();
                final name = nameController.text.trim();

                // optimistic UI: close dialog and show temporary saving indicator
                Navigator.of(ctx).pop();

                setState(() => _saving = true);

                final supabase = Supabase.instance.client;
                final createdAt = DateTime.now().toUtc().toIso8601String();
                final payload = {
                  'goalexpense': parsedGoal,
                  'daysperiod': days,
                  'category': category,
                  'name': name,
                  'created_at': createdAt,
                  'user_id': 1,
                };

                try {
                  final res = await supabase
                      .from('budgetgoals')
                      .insert(payload)
                      .select();
                  dynamic inserted;
                  if (res.isNotEmpty) {
                    inserted = res.first;
                  } else if (res is Map) {
                    inserted = res;
                  }

                  if (inserted != null) {
                    setState(() {
                      _data.add(inserted);
                      // keep deterministic ordering by created_at
                      _data.sort((a, b) {
                        final va = (a is Map)
                            ? (a['created_at'] ?? a['createdAt'])
                            : null;
                        final vb = (b is Map)
                            ? (b['created_at'] ?? b['createdAt'])
                            : null;
                        final da = va != null
                            ? DateTime.tryParse(va.toString())
                            : null;
                        final db = vb != null
                            ? DateTime.tryParse(vb.toString())
                            : null;
                        if (da == null && db == null) return 0;
                        if (da == null) return 1;
                        if (db == null) return -1;
                        return da.compareTo(db);
                      });
                    });
                  }
                } catch (e) {
                  // ignore for now
                } finally {
                  if (mounted) setState(() => _saving = false);
                }
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(),
      appBar: AppBar(title: const Text('Spezza')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: (_data.isEmpty)
            ? const Center(child: Text('No budget goals found.'))
            : ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  final item = _data[index];
                  final map = (item is Map)
                      ? Map<String, dynamic>.from(item)
                      : <String, dynamic>{};
                  return BudgetGoalInfo(data: map);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: Color(0xFF008000),
        child: _saving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
