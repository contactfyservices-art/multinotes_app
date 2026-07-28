# MultiNotes — projet Flutter

Cette appli reproduit les fonctionnalités visibles sur tes captures d'écran :
- Plusieurs **tableaux** (Principal / Travail / Famille + tableaux perso)
- Notes en **post-it colorés**, avec **police de texte** personnalisable
- Notes de type **checklist** (listes à cocher)
- **Rappels/alarmes** programmés sur une note (notifications)
- **Calendrier** affichant les notes qui ont un rappel
- **Pièces jointes** : image, document, position GPS
- Note protégée par **mot de passe**
- **Mode bulle flottante** (fenêtre par-dessus les autres applications)

Je n'ai pas pu compiler l'APK directement dans cet environnement (pas de
SDK Flutter/Android disponible ici), donc voici comment le faire toi-même —
c'est simple, ça prend 10-15 minutes la première fois.

## 1. Installer Flutter (une seule fois)

Si Flutter n'est pas déjà installé sur ton PC : suis
https://docs.flutter.dev/get-started/install (choisis Windows/Mac/Linux
selon ton PC). Vérifie avec :
```
flutter doctor
```

## 2. Récupérer le projet

Décompresse le fichier `multinotes_app.zip` que je t'ai donné, puis dans un
terminal, place-toi dans le dossier :
```
cd multinotes_app
flutter create . --platforms=android
```
Cette commande génère les dossiers manquants `android/`, `ios/` etc. (je ne
les ai pas inclus car ils dépendent de ta version exacte de Flutter).

## 3. Installer les dépendances
```
flutter pub get
```

## 4. Permissions Android (IMPORTANT pour le mode bulle + reste)

Ouvre `android/app/src/main/AndroidManifest.xml` et ajoute, juste avant
`<application ...>` :
```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
```

Toujours dans le même fichier, à l'intérieur de la balise `<application>`,
ajoute le service requis par `flutter_overlay_window` (regarde la doc du
package sur pub.dev pour la version exacte selon la release utilisée, le
package évolue) :
```xml
<service
    android:name="com.overlay.flutter_overlay_window.OverlayService"
    android:exported="false"
    android:foregroundServiceType="specialUse" />
```

## 5. Lancer l'appli
```
flutter run
```
ou pour un APK installable directement sur ton téléphone :
```
flutter build apk --release
```
L'APK se trouve ensuite dans `build/app/outputs/flutter-apk/app-release.apk`.

## Point important sur le "mode bulle"

Android **exige** que ce soit TOI, manuellement, qui autorises "Afficher
par-dessus les autres applications" pour chaque appli — aucune appli ne
peut s'auto-accorder cette permission (mesure de sécurité anti-arnaque).
Dans l'appli : Réglages > "Autorisation d'affichage par-dessus les autres
applis" > ça t'ouvre directement l'écran système Android où tu actives le
bouton. Sur les téléphones Xiaomi/Redmi/Poco (MIUI, comme sur tes
captures), il faut parfois AUSSI aller dans Réglages téléphone >
Applications > MultiNotes > Autorisations supplémentaires > activer
"Afficher au-dessus des autres fenêtres".

## Écran "À propos"

Accessible depuis Réglages > "À propos". Affiche ta photo (déjà incluse
dans `assets/images/profile.png`), ton nom, "ITPROG", le message de contact,
et deux boutons cliquables qui ouvrent directement WhatsApp et l'appli mail
avec tes coordonnées. Le package `url_launcher` gère ces ouvertures.

## Ce qui manque encore (à me redemander si tu veux que je le fasse)

- Lecture audio/vidéo des pièces jointes dans l'éditeur (actuellement
  seules les images s'affichent en miniature, le reste est un simple
  fichier joint)
- Thèmes/fonds d'écran illustrés comme "Fonds colorés" (j'ai mis une
  palette de couleurs simple, prête à être enrichie)
- Verrouillage de l'appli entière par empreinte digitale (`local_auth` est
  déjà dans les dépendances, prêt à l'emploi)
- Corbeille (notes supprimées récupérables)

## Structure du code

```
lib/
  models/        -> NoteModel, BoardModel (stockage Hive local)
  providers/      -> AppProvider (toute la logique d'état)
  services/       -> notifications (rappels), overlay (bulle flottante)
  screens/        -> accueil, éditeur de note, calendrier, réglages
  overlay_entry.dart -> mini-UI affichée dans la bulle flottante
  main.dart
```
