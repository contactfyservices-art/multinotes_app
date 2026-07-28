import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../models/note_model.dart';

/// Gère les rappels programmés (l'équivalent de la petite icône "réveil"
/// que tu vois sur chaque post-it dans MultiNotes).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'note_reminders',
      'Rappels de notes',
      description: 'Notifications de rappel pour vos notes',
      importance: Importance.max,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  int _idFromNoteId(String noteId) => noteId.hashCode & 0x7FFFFFFF;

  Future<void> scheduleReminder(NoteModel note) async {
    if (note.reminderAt == null) return;
    final scheduledDate = tz.TZDateTime.from(note.reminderAt!, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      _idFromNoteId(note.id),
      note.title.isEmpty ? 'Rappel de note' : note.title,
      note.type == NoteType.checklist
          ? '${note.checklistItems.length} élément(s) dans votre liste'
          : note.content,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'note_reminders',
          'Rappels de notes',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(String noteId) async {
    await _plugin.cancel(_idFromNoteId(noteId));
  }
}
