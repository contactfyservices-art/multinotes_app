import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/note_model.dart';
import '../providers/app_provider.dart';

const _kColors = [
  0xFFFFF59D, // jaune
  0xFFF48FB1, // rose
  0xFFA5D6A7, // vert
  0xFF90CAF9, // bleu
  0xFFFFCC80, // orange
  0xFFCE93D8, // violet
  0xFFFFFFFF, // blanc
];

const _kFonts = ['Default', 'Serif', 'Monospace', 'Cursive'];

class NoteEditorScreen extends StatefulWidget {
  final NoteModel note;
  final bool isNew;
  const NoteEditorScreen({super.key, required this.note, required this.isNew});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late NoteModel note;

  @override
  void initState() {
    super.initState();
    note = widget.note;
    _titleCtrl = TextEditingController(text: note.title);
    _contentCtrl = TextEditingController(text: note.content);
  }

  Future<void> _save() async {
    note.title = _titleCtrl.text;
    note.content = _contentCtrl.text;
    await context.read<AppProvider>().saveNote(note);
  }

  Future<void> _pickReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: note.reminderAt ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(note.reminderAt ?? DateTime.now()),
    );
    if (time == null) return;
    setState(() {
      note.reminderAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
    await _save();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => note.attachmentPaths.add(picked.path));
      await _save();
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() => note.attachmentPaths.add(result.files.single.path!));
      await _save();
    }
  }

  Future<void> _attachLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        note.latitude = pos.latitude;
        note.longitude = pos.longitude;
      });
      await _save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Position ajoutée à la note')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible de récupérer la position : $e')));
      }
    }
  }

  Future<void> _setPassword() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Protéger cette note'),
        content: TextField(controller: ctrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Valider')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final hash = sha256.convert(utf8.encode(result)).toString();
      setState(() => note.passwordHash = hash);
      await _save();
    }
  }

  void _addChecklistItem() {
    setState(() => note.checklistItems.add(ChecklistItem(label: '')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(note.colorValue),
      appBar: AppBar(
        backgroundColor: Color(note.colorValue),
        actions: [
          IconButton(icon: const Icon(Icons.alarm), tooltip: 'Rappel', onPressed: _pickReminder),
          IconButton(icon: const Icon(Icons.lock_outline), tooltip: 'Mot de passe', onPressed: _setPassword),
          IconButton(
            icon: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => note.isPinned = !note.isPinned),
          ),
          PopupMenuButton<int>(
            onSelected: (i) => setState(() => note.colorValue = _kColors[i]),
            itemBuilder: (_) => List.generate(
              _kColors.length,
              (i) => PopupMenuItem(
                value: i,
                child: Container(width: 24, height: 24, color: Color(_kColors[i])),
              ),
            ),
            icon: const Icon(Icons.palette),
          ),
          PopupMenuButton<String>(
            onSelected: (f) => setState(() => note.fontFamily = f),
            itemBuilder: (_) => _kFonts.map((f) => PopupMenuItem(value: f, child: Text(f))).toList(),
            icon: const Icon(Icons.font_download),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _titleCtrl,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(hintText: 'Titre', border: InputBorder.none),
                onChanged: (_) => _save(),
              ),
            ),
            const Divider(),
            Expanded(
              child: note.type == NoteType.checklist ? _buildChecklist() : _buildTextNote(),
            ),
            if (note.attachmentPaths.isNotEmpty) _buildAttachmentsPreview(),
            _buildToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: _contentCtrl,
        maxLines: null,
        expands: true,
        style: TextStyle(fontFamily: note.fontFamily == 'Default' ? null : note.fontFamily),
        decoration: const InputDecoration(hintText: 'Écris ta note ici...', border: InputBorder.none),
        onChanged: (_) => _save(),
      ),
    );
  }

  Widget _buildChecklist() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: note.checklistItems.length + 1,
      itemBuilder: (context, i) {
        if (i == note.checklistItems.length) {
          return ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Ajouter un élément'),
            onTap: _addChecklistItem,
          );
        }
        final item = note.checklistItems[i];
        return ListTile(
          leading: Checkbox(
            value: item.checked,
            onChanged: (v) {
              setState(() => item.checked = v ?? false);
              _save();
            },
          ),
          title: TextFormField(
            initialValue: item.label,
            decoration: const InputDecoration(border: InputBorder.none, hintText: 'Élément...'),
            style: TextDecoration.lineThrough == null
                ? null
                : TextStyle(decoration: item.checked ? TextDecoration.lineThrough : null),
            onChanged: (v) {
              item.label = v;
              _save();
            },
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              setState(() => note.checklistItems.removeAt(i));
              _save();
            },
          ),
        );
      },
    );
  }

  Widget _buildAttachmentsPreview() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: note.attachmentPaths.length,
        itemBuilder: (context, i) {
          final path = note.attachmentPaths[i];
          final isImage = path.toLowerCase().endsWith('.jpg') || path.toLowerCase().endsWith('.png');
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: isImage
                ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(File(path), width: 60, height: 60, fit: BoxFit.cover))
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.black12,
                    child: const Icon(Icons.insert_drive_file),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      color: Colors.black.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(icon: const Icon(Icons.image), tooltip: 'Image', onPressed: _pickImage),
          IconButton(icon: const Icon(Icons.attach_file), tooltip: 'Document', onPressed: _pickFile),
          IconButton(icon: const Icon(Icons.location_on), tooltip: 'Position GPS', onPressed: _attachLocation),
          IconButton(
            icon: Icon(note.type == NoteType.checklist ? Icons.notes : Icons.checklist),
            tooltip: 'Basculer en checklist / texte',
            onPressed: () {
              setState(() {
                note.type = note.type == NoteType.checklist ? NoteType.text : NoteType.checklist;
              });
              _save();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Supprimer la note',
            onPressed: () async {
              await context.read<AppProvider>().deleteNote(note.id);
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
