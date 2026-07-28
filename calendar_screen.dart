import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/app_provider.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final selected = _selectedDay ?? _focusedDay;
    final notesOfDay = app.notesOnDate(selected);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => app.notesOnDate(day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const Divider(),
          Expanded(
            child: notesOfDay.isEmpty
                ? const Center(child: Text('Aucun rappel ce jour-là'))
                : ListView.builder(
                    itemCount: notesOfDay.length,
                    itemBuilder: (context, i) {
                      final note = notesOfDay[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: SizedBox(
                          height: 120,
                          child: NoteCard(
                            note: note,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note, isNew: false))),
                            onLongPress: () {},
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
