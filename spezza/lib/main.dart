import 'package:flutter/material.dart';
import 'package:spezza/model/dto/goal_expense.dart';
import 'package:spezza/shared/repositories/goal_repository.dart';
import 'package:spezza/sidebar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/shared/supabase_config/supabase_credentials.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Function.apply(Supabase.initialize, [], supabaseOptions);

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Spezza',
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      home: Scaffold(
        drawer: Sidebar(),
        appBar: AppBar(title: const Text('Spezza')),
        body: Column(),
      ),
    );
  }
}
