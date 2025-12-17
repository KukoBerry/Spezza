import 'package:flutter/material.dart';

class Estrutura extends StatefulWidget {
  const Estrutura({super.key});

  @override
  State<Estrutura> createState() => _EstruturaState();
}

class _EstruturaState extends State<Estrutura> {
  final List<GastoModel> gastos = [
    GastoModel(
        data: "04/11/2025 - 19:43",
        valor: "240,00",
        local: "Petrobras",
        tipo: "Gasolina"),
    GastoModel(
        data: "04/11/2025 - 16:15",
        valor: "62,00",
        local: "Cinemark",
        tipo: "Lazer"),
    GastoModel(
        data: "03/11/2025 - 18:20",
        valor: "350,00",
        local: "Coelba",
        tipo: "Luz"),
    GastoModel(
        data: "01/11/2025 - 14:35",
        valor: "500,00",
        local: "Atakarejo",
        tipo: "Alimentação"),
  ];

  void adicionarGasto(GastoModel gasto) {
    setState(() {
      gastos.insert(0, gasto);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 20),
            const TrocarOpcao(),
            const SizedBox(height: 20),
            const Filtrar(),
            const Divider(color: Color(0xFF008000), thickness: 2),
            Expanded(child: ListaGastos(gastos: gastos)),
          ],
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Color(0xFF008000),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
            child: const Icon(Icons.add),
            onPressed: () async {
              final novoGasto = await showDialog<GastoModel>(
                context: context,
                builder: (context) => const DialogNovoGasto(),
              );

              if (novoGasto != null) {
                adicionarGasto(novoGasto);
              }
            },
          ),
        ),
      ],
    );
  }
}

class TrocarOpcao extends StatelessWidget {
  const TrocarOpcao({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        Botao(titulo: 'Metas'),
        Botao(titulo: 'Gastos'),
      ],
    );
  }
}

class Botao extends StatelessWidget {
  final String titulo;

  const Botao({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF008000),
        foregroundColor: Colors.white,
      ),
      onPressed: () {},
      child: Text(titulo, style: const TextStyle(fontSize: 32)),
    );
  }
}

class Filtrar extends StatelessWidget {
  const Filtrar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.filter_list_sharp),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Filtrar gastos...',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListaGastos extends StatelessWidget {
  final List<GastoModel> gastos;

  const ListaGastos({super.key, required this.gastos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: gastos.length,
      itemBuilder: (context, index) {
        final gasto = gastos[index];
        return Gastos(
          data: gasto.data,
          valor: gasto.valor,
          local: gasto.local,
          tipo: gasto.tipo,
        );
      },
    );
  }
}

class GastoModel {
  final String data;
  final String valor;
  final String local;
  final String tipo;

  GastoModel({
    required this.data,
    required this.valor,
    required this.local,
    required this.tipo,
  });
}

class DialogNovoGasto extends StatefulWidget {
  const DialogNovoGasto({super.key});

  @override
  State<DialogNovoGasto> createState() => _DialogNovoGastoState();
}

class _DialogNovoGastoState extends State<DialogNovoGasto> {
  final dataController = TextEditingController();
  final valorController = TextEditingController();
  final localController = TextEditingController();
  final tipoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Novo Gasto"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: dataController,
              decoration: const InputDecoration(labelText: "Data"),
            ),
            TextField(
              controller: valorController,
              decoration: const InputDecoration(labelText: "Valor"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: localController,
              decoration: const InputDecoration(labelText: "Local"),
            ),
            TextField(
              controller: tipoController,
              decoration: const InputDecoration(labelText: "Tipo"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              GastoModel(
                data: dataController.text,
                valor: valorController.text,
                local: localController.text,
                tipo: tipoController.text,
              ),
            );
          },
          child: const Text("Salvar"),
        ),
      ],
    );
  }
}

class Gastos extends StatelessWidget {
  final String data;
  final String valor;
  final String local;
  final String tipo;

  const Gastos({
    super.key,
    required this.data,
    required this.valor,
    required this.local,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        color: Color(0xFF008000),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data, style: const TextStyle(color: Colors.white, fontSize: 20)),
          const Divider(color: Colors.white, thickness: 2),
          Text(valor, style: const TextStyle(color: Colors.white, fontSize: 20)),
          const Divider(color: Colors.white, thickness: 2),
          Text(local, style: const TextStyle(color: Colors.white, fontSize: 20)),
          const Divider(color: Colors.white, thickness: 2),
          Text(tipo, style: const TextStyle(color: Colors.white, fontSize: 20)),
        ],
      ),
    );
  }
}