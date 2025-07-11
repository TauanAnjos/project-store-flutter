import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lista_compra.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ListaCompraAdapter()); // ✅ Registrar adapter da classe

  // Abrir box com tipo correto (ListaCompra)
  await Hive.openBox<ListaCompra>('compras_lista');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercadinho',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ListaComprasPage(),
    );
  }
}

class ListaComprasPage extends StatefulWidget {
  const ListaComprasPage({super.key});

  @override
  State<ListaComprasPage> createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  @override
  Widget build(BuildContext context) {
    final comprasBox = Hive.box<ListaCompra>('compras_lista');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas de Compras'),
      ),
      body: ValueListenableBuilder(
        valueListenable: comprasBox.listenable(),
        builder: (context, Box<ListaCompra> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('Nenhuma lista cadastrada.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index);
              final lista = box.get(key);

              if (lista == null) return const SizedBox.shrink();

              return ListTile(
                title: Text(lista.titulo),
                subtitle: Text(
                  'Data: ${_formatarData(lista.data)}\n'
                  'Status: ${lista.status} | Valor: R\$ ${lista.valorTotal.toStringAsFixed(2)}',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    box.delete(key);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoAdicionar(context),
        tooltip: 'Nova Lista',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  void _mostrarDialogoAdicionar(BuildContext context) {
    final comprasBox = Hive.box<ListaCompra>('compras_lista');
    final tituloController = TextEditingController();
    final valorController = TextEditingController();
    String statusSelecionado = 'Pendente';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Lista de Compras'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: valorController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Valor Total'),
                ),
                DropdownButton<String>(
                  value: statusSelecionado,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        statusSelecionado = value;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'Pendente',
                      child: Text('Pendente'),
                    ),
                    DropdownMenuItem(
                      value: 'Concluída',
                      child: Text('Concluída'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final titulo = tituloController.text.trim();
                final valor =
                    double.tryParse(valorController.text.trim()) ?? 0.0;

                if (titulo.isNotEmpty) {
                  final novaLista = ListaCompra(
                    titulo: titulo,
                    data: DateTime.now(),
                    status: statusSelecionado,
                    valorTotal: valor,
                  );
                  comprasBox.add(novaLista);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Salvar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
