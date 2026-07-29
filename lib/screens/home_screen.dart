import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/note_model.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final boards = app.boards;

    return DefaultTabController(
      length: boards.length,
      initialIndex: boards.indexWhere((b) => b.id == app.selectedBoardId).clamp(0, boards.length - 1),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notiko'),
          bottom: TabBar(
            isScrollable: true,
            onTap: (i) => app.selectedBoardId = boards[i].id,
            tabs: boards
                .map((b) => Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(IconData(b.iconCode, fontFamily: 'MaterialIcons'), size: 18, color: Color(b.colorValue)),
                          const SizedBox(width: 6),
                          Text(b.name),
                        ],
                      ),
                    ))
                .toList(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              tooltip: 'Calendrier',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Réglages',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
          ],
        ),
        body: TabBarView(
          children: boards
              .map((b) => RefreshIndicator(
                    onRefresh: () async => app.refresh(),
                    child: _BoardGrid(boardId: b.id),
                  ))
              .toList(),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'checklist',
              mini: true,
              tooltip: 'Nouvelle checklist',
              onPressed: () => _createNote(context, NoteType.checklist),
              child: const Icon(Icons.checklist),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'text',
              tooltip: 'Nouvelle note',
              onPressed: () => _createNote(context, NoteType.text),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  void _createNote(BuildContext context, NoteType type) {
    final app = context.read<AppProvider>();
    final note = app.createNote(app.selectedBoardId, type: type);
    Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note, isNew: true)));
  }
}

class _BoardGrid extends StatelessWidget {
  final String boardId;
  const _BoardGrid({required this.boardId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final notes = app.notesForBoard(boardId);

    if (notes.isEmpty) {
      return ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                "Aucune note ici pour l'instant.\nAppuie sur + pour en créer une.",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: notes.length,
      itemBuilder: (context, i) {
        final note = notes[i];
        return NoteCard(
          note: note,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note, isNew: false))),
          onLongPress: () => _showQuickActions(context, note),
        );
      },
    );
  }

  void _showQuickActions(BuildContext context, NoteModel note) {
    final app = context.read<AppProvider>();
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: Text(note.isPinned ? 'Désépingler' : 'Épingler'),
              onTap: () {
                app.togglePin(note);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer'),
              onTap: () {
                app.deleteNote(note.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
