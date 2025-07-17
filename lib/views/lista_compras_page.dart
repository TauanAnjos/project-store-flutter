import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/lista_compra.dart';
import 'cadastro_lista_page.dart';
import '../services/hive_service.dart';

class ListaComprasPage extends StatefulWidget {
  const ListaComprasPage({super.key});

  @override
  State<ListaComprasPage> createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  @override
  Widget build(BuildContext context) {
    final comprasBox = HiveService.getListaComprasBox();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo_mercado.png',
              height: 32,
            ),
            const SizedBox(width: 12),
            const Text('Listas de Compras'),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: comprasBox.listenable(),
        builder: (context, Box<ListaCompra> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma lista cadastrada.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index);
              final lista = box.get(key);

              if (lista == null) return const SizedBox.shrink();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  title: Text(
                    lista.titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Data: ${_formatarData(lista.data)}\n'
                      'Status: ${lista.status} | Valor: R\$ ${lista.valorTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmarDelete(key),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroListaPage()),
          );
        },
        tooltip: 'Nova Lista',
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  void _confirmarDelete(dynamic key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta lista?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            onPressed: () {
              HiveService.getListaComprasBox().delete(key);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
