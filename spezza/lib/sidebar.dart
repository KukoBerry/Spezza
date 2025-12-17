import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/theme_provider.dart';
import 'package:spezza/view/screens/graphic_overview_screen.dart';

import 'home.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Fulano'),
            accountEmail: Text('fln.tal@mail.com'),
            decoration: BoxDecoration(color: Color(0xFF008000)),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Página inicial'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Home(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.pie_chart),
            title: Text('Visão geral'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GraphicOverviewScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.nightlight_round),
            title: Text('Modo escuro'),
            onTap: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configurações'),
            onTap: () => {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Mudar de conta'),
            onTap: () => {},
          ),
        ],
      ),
    );
  }
}
