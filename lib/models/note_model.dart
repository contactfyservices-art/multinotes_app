import 'package:hive/hive.dart';

part 'note_model.g.dart';

/// Types de notes supportés : texte libre, checklist (todo), note vocale...
@HiveType(typeId: 0)
enum NoteType {
  @HiveField(0)
  text,
  @HiveField(1)
  checklist,
}

@HiveType(typeId: 1)
class ChecklistItem extends HiveObject {
  @HiveField(0)
  String label;
  @HiveField(1)
  bool checked;

  ChecklistItem({required this.label, this.checked = false});
}

/// Une note façon "post-it" : couleur, police, pièces jointes, rappel, etc.
@HiveType(typeId: 2)
class NoteModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String boardId; // à quel tableau appartient la note (Principal / Travail / Famille...)

  @HiveField(2)
  String title;

  @HiveField(3)
  String content;

  @HiveField(4)
  NoteType type;

  @HiveField(5)
  List<ChecklistItem> checklistItems;

  @HiveField(6)
  int colorValue; // couleur du post-it (ARGB)

  @HiveField(7)
  String fontFamily; // police choisie (Style de texte)

  @HiveField(8)
  bool isBold;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  @HiveField(11)
  DateTime? reminderAt; // date/heure du rappel (alarme)

  @HiveField(12)
  bool isPinned;

  @HiveField(13)
  List<String> attachmentPaths; // images, vidéos, pdf, audio joints

  @HiveField(14)
  String? passwordHash; // note protégée par mot de passe

  @HiveField(15)
  bool readOnly;

  @HiveField(16)
  double? latitude;

  @HiveField(17)
  double? longitude;

  @HiveField(18)
  int backgroundIndex; // fond/thème choisi (Fonds colorés)

  NoteModel({
    required this.id,
    required this.boardId,
    this.title = '',
    this.content = '',
    this.type = NoteType.text,
    List<ChecklistItem>? checklistItems,
    this.colorValue = 0xFFFFF59D, // jaune post-it par défaut
    this.fontFamily = 'Default',
    this.isBold = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.reminderAt,
    this.isPinned = false,
    List<String>? attachmentPaths,
    this.passwordHash,
    this.readOnly = false,
    this.latitude,
    this.longitude,
    this.backgroundIndex = 0,
  })  : checklistItems = checklistItems ?? [],
        attachmentPaths = attachmentPaths ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}
