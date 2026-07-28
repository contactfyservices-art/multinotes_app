// GENERATED CODE - manually written to match build_runner output exactly.
// Si tu modifies note_model.dart, tu peux régénérer ce fichier avec :
//   flutter pub run build_runner build --delete-conflicting-outputs

part of 'note_model.dart';

class NoteTypeAdapter extends TypeAdapter<NoteType> {
  @override
  final int typeId = 0;

  @override
  NoteType read(BinaryReader reader) {
    final index = reader.readByte();
    return NoteType.values[index];
  }

  @override
  void write(BinaryWriter writer, NoteType obj) {
    writer.writeByte(obj.index);
  }
}

class ChecklistItemAdapter extends TypeAdapter<ChecklistItem> {
  @override
  final int typeId = 1;

  @override
  ChecklistItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChecklistItem(
      label: fields[0] as String,
      checked: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ChecklistItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.checked);
  }
}

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 2;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      id: fields[0] as String,
      boardId: fields[1] as String,
      title: fields[2] as String,
      content: fields[3] as String,
      type: fields[4] as NoteType,
      checklistItems: (fields[5] as List).cast<ChecklistItem>(),
      colorValue: fields[6] as int,
      fontFamily: fields[7] as String,
      isBold: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      reminderAt: fields[11] as DateTime?,
      isPinned: fields[12] as bool,
      attachmentPaths: (fields[13] as List).cast<String>(),
      passwordHash: fields[14] as String?,
      readOnly: fields[15] as bool,
      latitude: fields[16] as double?,
      longitude: fields[17] as double?,
      backgroundIndex: fields[18] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.boardId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.checklistItems)
      ..writeByte(6)
      ..write(obj.colorValue)
      ..writeByte(7)
      ..write(obj.fontFamily)
      ..writeByte(8)
      ..write(obj.isBold)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.reminderAt)
      ..writeByte(12)
      ..write(obj.isPinned)
      ..writeByte(13)
      ..write(obj.attachmentPaths)
      ..writeByte(14)
      ..write(obj.passwordHash)
      ..writeByte(15)
      ..write(obj.readOnly)
      ..writeByte(16)
      ..write(obj.latitude)
      ..writeByte(17)
      ..write(obj.longitude)
      ..writeByte(18)
      ..write(obj.backgroundIndex);
  }
}
