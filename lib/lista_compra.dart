import 'package:hive/hive.dart';

part 'lista_compra.g.dart';

@HiveType(typeId: 0)
class ListaCompra extends HiveObject {
  @HiveField(0)
  String titulo;

  @HiveField(1)
  DateTime data;

  @HiveField(2)
  String status; // Ex: "Pendente", "Concluída"

  @HiveField(3)
  double valorTotal;

  ListaCompra({
    required this.titulo,
    required this.data,
    required this.status,
    required this.valorTotal,
  });
}
