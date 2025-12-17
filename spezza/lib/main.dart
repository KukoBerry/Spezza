import 'package:flutter/material.dart';
import 'package:spezza/home.dart';
import 'package:spezza/login.dart';
import 'package:spezza/model/dto/goal_expense.dart';
import 'package:spezza/model/goal_expense_model.dart';
import 'package:spezza/shared/repositories/goal_repository.dart';
import 'package:spezza/sidebar.dart';
import 'package:spezza/theme_provider.dart';
import 'package:spezza/view_model/home_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/shared/supabase_config/supabase_credentials.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Function.apply(Supabase.initialize, [], supabaseOptions);

  runApp(ProviderScope(child: MyApp()));
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
      home: Home(),
    );
  }
}
