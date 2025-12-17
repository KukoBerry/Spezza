import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/model/dto/goal_expense.dart';
import 'package:spezza/shared/repositories/goal_repository.dart';
import 'package:spezza/shared/supabase_config/supabase_credentials.dart';
import 'package:spezza/sidebar.dart';
import 'package:spezza/theme_provider.dart';
import 'package:spezza/view/widgets/budget_goal_info.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Function.apply(Supabase.initialize, [], supabaseOptions);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

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
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<GoalExpense> _goals = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final list = await ref.read(goalRepositoryProvider).fetchGoals();
      if (!mounted) return;
      setState(() => _goals = list);
    } catch (_) {}
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
                  final inserted = await ref
                      .read(goalRepositoryProvider)
                      .addGoal(payload);
                  if (inserted != null) {
                    if (inserted is Map) {
                      try {
                        final created = GoalExpense.fromMap(
                          Map<String, dynamic>.from(inserted),
                        );
                        setState(() => _goals.add(created));
                      } catch (_) {
                        await _loadGoals();
                      }
                    } else if (inserted is GoalExpense) {
                      setState(() => _goals.add(inserted));
                    } else {
                      try {
                        final created = GoalExpense.fromMap(
                          Map<String, dynamic>.from(inserted as Map),
                        );
                        setState(() => _goals.add(created));
                      } catch (_) {
                        await _loadGoals();
                      }
                    }
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
        child: (_goals.isEmpty)
            ? const Center(child: Text('Sem metas encontradas.'))
            : ListView.builder(
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  final item = _goals[index];
                  return BudgetGoalInfo(goal: item);
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
