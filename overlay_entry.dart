import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// Ce point d'entrée est lancé par le SYSTÈME ANDROID (pas par ton code Dart
/// normal) quand la bulle flottante est affichée. Il doit rester léger :
/// pas d'accès direct à Hive ici (process séparé) — on communique avec
/// l'appli principale via FlutterOverlayWindow.shareData si besoin.
@pragma('vm:entry-point')
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _BubbleQuickNote(),
  ));
}

class _BubbleQuickNote extends StatefulWidget {
  const _BubbleQuickNote();

  @override
  State<_BubbleQuickNote> createState() => _BubbleQuickNoteState();
}

class _BubbleQuickNoteState extends State<_BubbleQuickNote> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF59D),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Note rapide', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                GestureDetector(
                  onTap: () => FlutterOverlayWindow.closeOverlay(),
                  child: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Écris ta note...',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Envoie le texte à l'appli principale pour qu'elle
                // l'enregistre dans Hive (voir main.dart : SharedData listener).
                FlutterOverlayWindow.shareData(_controller.text);
                _controller.clear();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
