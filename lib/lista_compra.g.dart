// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lista_compra.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ListaCompraAdapter extends TypeAdapter<ListaCompra> {
  @override
  final int typeId = 0;

  @override
  ListaCompra read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListaCompra(
      titulo: fields[0] as String,
      data: fields[1] as DateTime,
      status: fields[2] as String,
      valorTotal: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ListaCompra obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.titulo)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.valorTotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListaCompraAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
