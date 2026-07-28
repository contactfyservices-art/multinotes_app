import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteCard({super.key, required this.note, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Color(note.colorValue),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (note.reminderAt != null) ...[
                  const Icon(Icons.alarm, size: 14),
                  const SizedBox(width: 4),
                  Text(DateFormat('dd/MM HH:mm').format(note.reminderAt!), style: const TextStyle(fontSize: 11)),
                ],
                const Spacer(),
                if (note.isPinned) const Icon(Icons.push_pin, size: 14),
                if (note.passwordHash != null) const Icon(Icons.lock, size: 14),
              ],
            ),
            if (note.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(note.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: note.fontFamily == 'Default' ? null : note.fontFamily)),
              ),
            const SizedBox(height: 4),
            Expanded(child: _buildBody()),
            if (note.attachmentPaths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 14),
                    const SizedBox(width: 2),
                    Text('${note.attachmentPaths.length}', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (note.type == NoteType.checklist) {
      final items = note.checklistItems.take(4).toList();
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: items
            .map((it) => Row(
                  children: [
                    Icon(it.checked ? Icons.check_box : Icons.check_box_outline_blank, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        it.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          decoration: it.checked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ))
            .toList(),
      );
    }
    return Text(
      note.content,
      maxLines: 6,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        fontFamily: note.fontFamily == 'Default' ? null : note.fontFamily,
        fontWeight: note.isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
