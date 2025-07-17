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

          final listas = box.values.toList();
          final totalComprado = listas
              .where((item) => item.status.toLowerCase() == 'comprado')
              .fold(0.0, (soma, item) => soma + item.valorTotal);

          final totalAComprar = listas
              .where((item) => item.status.toLowerCase() == 'a comprar')
              .fold(0.0, (soma, item) => soma + item.valorTotal);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
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
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        title: Text(
                          lista.titulo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data: ${_formatarData(lista.data)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  children: [
                                    const TextSpan(text: 'Status: '),
                                    TextSpan(
                                      text: lista.status,
                                      style: TextStyle(
                                        color: lista.status == 'comprado'
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' | Valor: R\$ ${lista.valorTotal.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                width: double.infinity,
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 16),
                        children: [
                          const TextSpan(
                            text: 'Total gasto (comprado): ',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'R\$ ${totalComprado.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 16),
                        children: [
                          const TextSpan(
                            text: 'Total estimado (a comprar): ',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'R\$ ${totalAComprar.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
