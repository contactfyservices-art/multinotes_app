import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import '../models/board_model.dart';
import '../services/notification_service.dart';

/// Gère toute la donnée de l'appli (notes + tableaux) et notifie l'UI.
class AppProvider extends ChangeNotifier {
  static const _notesBoxName = 'notes';
  static const _boardsBoxName = 'boards';
  final _uuid = const Uuid();

  late Box<NoteModel> _notesBox;
  late Box<BoardModel> _boardsBox;

  String selectedBoardId = 'principal';

  List<NoteModel> get allNotes => _notesBox.values.toList();

  List<NoteModel> notesForBoard(String boardId) {
    final list = _notesBox.values.where((n) => n.boardId == boardId).toList();
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  List<BoardModel> get boards {
    final list = _boardsBox.values.toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteTypeAdapter());
    Hive.registerAdapter(ChecklistItemAdapter());
    Hive.registerAdapter(NoteModelAdapter());
    Hive.registerAdapter(BoardModelAdapter());

    _notesBox = await Hive.openBox<NoteModel>(_notesBoxName);
    _boardsBox = await Hive.openBox<BoardModel>(_boardsBoxName);

    if (_boardsBox.isEmpty) {
      // Tableaux par défaut, comme dans les captures : Principal / Travail / Famille
      await _boardsBox.put(
        'principal',
        BoardModel(id: 'principal', name: 'Principal', colorValue: 0xFF4CAF50, iconCode: 0xe002, order: 0),
      );
      await _boardsBox.put(
        'travail',
        BoardModel(id: 'travail', name: 'Travail', colorValue: 0xFFAFB42B, iconCode: 0xe7fd, order: 1),
      );
      await _boardsBox.put(
        'famille',
        BoardModel(id: 'famille', name: 'Famille', colorValue: 0xFF00BCD4, iconCode: 0xe87c, order: 2),
      );
    }

    await NotificationService.instance.init();
    notifyListeners();
  }

  BoardModel? boardById(String id) {
    try {
      return _boardsBox.values.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addBoard(String name, {int colorValue = 0xFF9C27B0, int iconCode = 0xe2c7}) async {
    final id = _uuid.v4();
    await _boardsBox.put(id, BoardModel(id: id, name: name, colorValue: colorValue, iconCode: iconCode, order: boards.length));
    notifyListeners();
  }

  Future<void> deleteBoard(String id) async {
    await _boardsBox.delete(id);
    final toRemove = _notesBox.values.where((n) => n.boardId == id).map((n) => n.id).toList();
    for (final noteId in toRemove) {
      await _notesBox.delete(noteId);
    }
    notifyListeners();
  }

  NoteModel createNote(String boardId, {NoteType type = NoteType.text}) {
    final id = _uuid.v4();
    return NoteModel(id: id, boardId: boardId, type: type);
  }

  Future<void> saveNote(NoteModel note) async {
    note.updatedAt = DateTime.now();
    await _notesBox.put(note.id, note);
    if (note.reminderAt != null) {
      await NotificationService.instance.scheduleReminder(note);
    } else {
      await NotificationService.instance.cancelReminder(note.id);
    }
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await NotificationService.instance.cancelReminder(id);
    await _notesBox.delete(id);
    notifyListeners();
  }

  Future<void> togglePin(NoteModel note) async {
    note.isPinned = !note.isPinned;
    await saveNote(note);
  }

  List<NoteModel> notesOnDate(DateTime day) {
    return allNotes.where((n) {
      if (n.reminderAt == null) return false;
      final r = n.reminderAt!;
      return r.year == day.year && r.month == day.month && r.day == day.day;
    }).toList();
  }
}
