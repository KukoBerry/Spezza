import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

void main() {
  runApp(ProviderScope(child: MaterialApp(home: MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int numeroSorteado = ref.watch(sorteioProvider);
    return Scaffold(body: Text('Número: $numeroSorteado'));
  }
}

@riverpod
int sorteio(Ref ref) {
  debugPrint("Executou a função sorteio");
  return Random().nextInt(100);
}