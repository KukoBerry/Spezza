import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/shared/supabase_config/supabase_credentials.dart';
import 'package:spezza/sidebar.dart';
import 'package:spezza/theme_provider.dart';
import 'package:spezza/view/widgets/budget_goal_info.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Function.apply(Supabase.initialize, [], supabaseOptions);

  final supabase = Supabase.instance.client;

  final data = await supabase.from('budgetgoals').select();

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
      home: Scaffold(
        drawer: Sidebar(),
        appBar: AppBar(title: const Text('Spezza')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: (initialData == null || initialData!.isEmpty)
              ? const Center(child: Text('No budget goals found.'))
              : ListView.builder(
                  itemCount: initialData!.length,
                  itemBuilder: (context, index) {
                    final item = initialData![index];
                    // Ensure we pass a Map<String, dynamic>
                    final map = (item is Map)
                        ? Map<String, dynamic>.from(item)
                        : <String, dynamic>{};
                    return BudgetGoalInfo(data: map);
                  },
                ),
        ),
      ),
    );
  }
}
