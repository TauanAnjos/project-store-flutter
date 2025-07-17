import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/lista_compra.dart';
import '../services/hive_service.dart';

class CadastroListaPage extends StatefulWidget {
  const CadastroListaPage({super.key});

  @override
  State<CadastroListaPage> createState() => _CadastroListaPageState();
}

class _CadastroListaPageState extends State<CadastroListaPage> {
  final _tituloController = TextEditingController();
  final _valorController = TextEditingController();
  String _statusSelecionado = 'a comprar';
  DateTime _dataSelecionada = DateTime.now();

  final _formKey = GlobalKey<FormState>();

  static const primaryColor = Color(0xFF4CAF50); // Verde mercado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Lista de Compras'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título da lista',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.list_alt),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _valorController,
                decoration: InputDecoration(
                  labelText: 'Valor da compra',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final valor = double.tryParse(value ?? '');
                  if (valor == null || valor <= 0) {
                    return 'Informe um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Data da compra: ',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${_dataSelecionada.day.toString().padLeft(2, '0')}/'
                    '${_dataSelecionada.month.toString().padLeft(2, '0')}/'
                    '${_dataSelecionada.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: primaryColor),
                    onPressed: _selecionarData,
                  )
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _statusSelecionado,
                decoration: InputDecoration(
                  labelText: 'Status da compra',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.info_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'a comprar', child: Text('A Comprar')),
                  DropdownMenuItem(value: 'comprado', child: Text('Comprado')),
                ],
                onChanged: (value) {
                  setState(() {
                    _statusSelecionado = value!;
                  });
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: _salvarLista,
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // ✅ Aqui foi alterado
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selecionarData() async {
    final novaData = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (novaData != null) {
      setState(() {
        _dataSelecionada = novaData;
      });
    }
  }

  void _salvarLista() {
    if (_formKey.currentState?.validate() ?? false) {
      final novaLista = ListaCompra(
        titulo: _tituloController.text.trim(),
        data: _dataSelecionada,
        status: _statusSelecionado,
        valorTotal: double.parse(_valorController.text.trim()),
      );

      HiveService.getListaComprasBox().add(novaLista);

      Navigator.of(context).pop();
    }
  }
}
