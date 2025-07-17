import 'package:hive_flutter/hive_flutter.dart';
import '../models/lista_compra.dart';

class HiveService {
  static const String boxName = 'compras_lista';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ListaCompraAdapter());
    await Hive.openBox<ListaCompra>(boxName);
  }

  static Box<ListaCompra> getListaComprasBox() {
    return Hive.box<ListaCompra>(boxName);
  }
}
