// GENERATED CODE - manually written to match build_runner output exactly.
part of 'board_model.dart';

class BoardModelAdapter extends TypeAdapter<BoardModel> {
  @override
  final int typeId = 3;

  @override
  BoardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoardModel(
      id: fields[0] as String,
      name: fields[1] as String,
      colorValue: fields[2] as int,
      iconCode: fields[3] as int,
      order: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BoardModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorValue)
      ..writeByte(3)
      ..write(obj.iconCode)
      ..writeByte(4)
      ..write(obj.order);
  }
}
