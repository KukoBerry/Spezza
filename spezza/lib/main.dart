import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'main.g.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://twztngpknaldevuxjpwi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR3enRuZ3BrbmFsZGV2dXhqcHdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxNzUxNjcsImV4cCI6MjA3OTc1MTE2N30.vSpV5c9Xj2Ob0Me35c6arJHEXPzhoaYpJzthYSDY5IA',
  );
  final List<Map<String, dynamic>> results = await Supabase.instance.client.from('budgetgoals').select();

  runApp(ProviderScope(child: MaterialApp(home: MyApp(results))));
}

class MyApp extends ConsumerWidget {
  final List<Map<String, dynamic>> results;
  const MyApp(this.results, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int numeroSorteado = ref.watch(sorteioProvider);
    return Scaffold(
      body: Column(
        children: [
          Text(results.toString(), textDirection: TextDirection.ltr),
          Text('Número: $numeroSorteado'),
        ],
      )
    );
  }
}

@riverpod
int sorteio(Ref ref) {
  debugPrint("Executou a função sorteio");
  return Random().nextInt(100);
}