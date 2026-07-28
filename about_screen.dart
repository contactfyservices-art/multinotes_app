import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Écran "À propos" : présente le créateur de l'application et ses
/// coordonnées, avec des boutons directs vers WhatsApp et l'e-mail.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _whatsappNumber = '+261334175026'; // sans espaces, format international
  static const _email = 'contact.fy.services@gmail.com';
  static const _developerName = 'Fy ANDRIANANTENAINA';
  static const _company = 'ITPROG';

  Future<void> _openWhatsApp() async {
    final phone = _whatsappNumber.replaceAll('+', '').replaceAll(' ', '');
    final uri = Uri.parse('https://wa.me/$phone');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      query: 'subject=Contact depuis MultiNotes',
    );
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 70,
              backgroundImage: const AssetImage('assets/images/profile.png'),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _developerName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              _company,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600, letterSpacing: 1.2),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Vous voulez développer vos idées à travers des applications "
                "de vos rêves ? N'hésitez pas à me contacter.",
                style: TextStyle(fontSize: 15, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.green),
                  title: const Text('WhatsApp'),
                  subtitle: const Text(_whatsappNumber),
                  onTap: _openWhatsApp,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: const Text('E-mail'),
                  subtitle: const Text(_email),
                  onTap: _sendEmail,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'MultiNotes — v1.0.0',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
