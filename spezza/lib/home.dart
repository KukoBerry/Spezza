import 'package:flutter/material.dart';
import 'package:spezza/sidebar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(),
      appBar: AppBar(title: const Text('Spezza')),
      body: Column(),
    );
  }
}
