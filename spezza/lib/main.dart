import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spezza/goal_expense.dart';
import 'package:spezza/goal_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
//part 'main.g.dart';

final goalReositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository();
});

final fetchGoalsProvider = FutureProvider<List<GoalExpense>>((ref) async {
  final repository = ref.watch(goalReositoryProvider);
  return repository.fetchGoals();
});

void main() async {
  await Supabase.initialize(
    url: 'https://twztngpknaldevuxjpwi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR3enRuZ3BrbmFsZGV2dXhqcHdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxNzUxNjcsImV4cCI6MjA3OTc1MTE2N30.vSpV5c9Xj2Ob0Me35c6arJHEXPzhoaYpJzthYSDY5IA',
  );

  runApp(ProviderScope(child: MaterialApp(home: MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGoals = ref.watch(fetchGoalsProvider);

    return MaterialApp(
      title: 'Spezza',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Spezza')),
        body: asyncGoals.when(
          data: (goals) => MainInfo(goals: goals),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class MainInfo extends StatelessWidget {
  final List<GoalExpense> goals;

  const MainInfo({super.key, required this.goals});

  double get totalGoal => goals.fold(0, (sum, goal) => sum + goal.goal);

  double get totalSpent => goals.fold(0, (sum, goal) => sum + goal.amountSpent);

  double get totalRemaining => totalGoal - totalSpent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Total máximo disponível'),
                      Text(
                        'R\$${totalRemaining.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Total gasto'),
                      Text(
                        'R\$${totalSpent.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return Card(
                child: ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text('Objetivo: \$${goal.goal.toStringAsFixed(2)}'),
                  subtitle: Text(
                    'Total gasto: \$${goal.amountSpent.toStringAsFixed(2)}',
                  ),
                  trailing: Icon(Icons.arrow_forward),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spezza',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spezza')),
      body: Center(child: Text('Main Page')),
    );
  }
}
