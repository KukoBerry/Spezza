import 'package:flutter/material.dart';
import 'package:spezza/sidebar.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(),
      appBar: AppBar(title: const Text('Spezza')),
      body: Column(),
    );
  }
}