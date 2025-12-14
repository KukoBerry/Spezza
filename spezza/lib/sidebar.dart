import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
              accountName: Text('Fulano'),
              accountEmail: Text('fln.tal@mail.com'),
              decoration: BoxDecoration(
                color: Colors.green
              ),
          ),
          ListTile(
            leading: Icon(Icons.pie_chart),
            title: Text('Visão geral'),
            onTap: () => print('Ou overview; Muda pra Gráficos Gerais'),
          ),
          ListTile(
            leading: Icon(Icons.nightlight_round),
            title: Text('Modo escuro'),
            onTap: () => print('Faz toggle de modo escuro'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configurações'),
            onTap: () => print('lol q configurações?'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Mudar de conta'),
            onTap: () => print('Bem intuitivo'),
          )
        ],
      )
    );
  }
}
