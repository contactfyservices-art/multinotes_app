import 'package:hive/hive.dart';

part 'board_model.g.dart';

/// Un "tableau" façon onglets Principal / Travail / Famille dans MultiNotes.
@HiveType(typeId: 3)
class BoardModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue;

  @HiveField(3)
  int iconCode; // codePoint d'une IconData

  @HiveField(4)
  int order;

  BoardModel({
    required this.id,
    required this.name,
    this.colorValue = 0xFF4CAF50,
    this.iconCode = 0xe645, // Icons.warning par défaut
    this.order = 0,
  });
}
