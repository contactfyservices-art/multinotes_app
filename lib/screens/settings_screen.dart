import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/overlay_service.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool? _overlayGranted;

  @override
  void initState() {
    super.initState();
    _checkOverlay();
  }

  Future<void> _checkOverlay() async {
    final granted = await OverlayService.instance.hasPermission();
    if (mounted) setState(() => _overlayGranted = granted);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        children: [
          const ListTile(title: Text('Tableaux', style: TextStyle(fontWeight: FontWeight.bold))),
          ...app.boards.map((b) => ListTile(
                leading: Icon(IconData(b.iconCode, fontFamily: 'MaterialIcons'), color: Color(b.colorValue)),
                title: Text(b.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => app.deleteBoard(b.id),
                ),
              )),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Ajouter un tableau'),
            onTap: () => _addBoardDialog(context, app),
          ),
          const Divider(),
          const ListTile(title: Text('Mode bulle flottante', style: TextStyle(fontWeight: FontWeight.bold))),
          SwitchListTile(
            title: const Text("Autorisation d'affichage par-dessus les autres applis"),
            subtitle: Text(_overlayGranted == null
                ? 'Vérification...'
                : _overlayGranted!
                    ? 'Activée : la bulle flottante peut fonctionner'
                    : "Non activée : appuie pour aller dans les réglages Android"),
            value: _overlayGranted ?? false,
            onChanged: (_) async {
              await OverlayService.instance.requestPermission();
              await _checkOverlay();
            },
          ),
          ListTile(
            leading: const Icon(Icons.blur_circular),
            title: const Text('Lancer la bulle maintenant'),
            onTap: () => OverlayService.instance.showBubble(),
          ),
          const Divider(),
          const ListTile(
            title: Text('Sécurité', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Le mot de passe se définit note par note (icône cadenas dans l\'éditeur).'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('À propos'),
            subtitle: const Text('Créateur de l\'application, contact'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
        ],
      ),
    );
  }

  Future<void> _addBoardDialog(BuildContext context, AppProvider app) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouveau tableau'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Nom du tableau')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Créer')),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await app.addBoard(name.trim());
    }
  }
}
