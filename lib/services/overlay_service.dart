import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';

/// Gère le mode "bulle flottante" (comme Messenger) : une petite fenêtre
/// MultiNotes qui reste affichée par-dessus les autres applications.
///
/// IMPORTANT : ceci nécessite la permission Android "Afficher par-dessus
/// les autres applications" (SYSTEM_ALERT_WINDOW), qui doit être accordée
/// manuellement par l'utilisateur (Android l'exige pour des raisons de
/// sécurité, aucune appli ne peut l'auto-accorder).
class OverlayService {
  OverlayService._();
  static final OverlayService instance = OverlayService._();

  /// Vérifie si la permission "overlay" est déjà accordée.
  Future<bool> hasPermission() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  /// Ouvre l'écran système où l'utilisateur active la permission.
  Future<void> requestPermission() async {
    await FlutterOverlayWindow.requestPermission();
    // Sur certains constructeurs (Xiaomi/Mi, comme sur tes captures),
    // il faut aussi activer "Autorisations supplémentaires > Afficher
    // au-dessus des autres fenêtres" manuellement dans les réglages MIUI.
  }

  /// Affiche la bulle flottante (mini note toujours visible à l'écran).
  Future<void> showBubble() async {
    final granted = await hasPermission();
    if (!granted) {
      await requestPermission();
      return;
    }
    await FlutterOverlayWindow.showOverlay(
      height: 260,
      width: 260,
      alignment: OverlayAlignment.centerRight,
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      enableDrag: true,
    );
  }

  Future<void> closeBubble() async {
    await FlutterOverlayWindow.closeOverlay();
  }

  Future<bool> isActive() async {
    return await FlutterOverlayWindow.isActive();
  }
}
