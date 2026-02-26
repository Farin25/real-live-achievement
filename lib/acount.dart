import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column( // Alle Widgets müssen in DIESE Column
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.person, size: 35, color: Colors.white),
                ),
                const SizedBox(width: 15), // Kleiner Abstand zwischen Bild und Text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Text(_usernameController.text)',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Liam Selent',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 30), // Hier war der Tippfehler "cons"

            const Expanded(
              child: Center(
                child: Text(
                  'Hier kommen später deine Account Settings rein.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            /// Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await supabase.auth.signOut();
                },
                child: const Text('Abmelden'),
              ),
            ),

            const SizedBox(height: 12),

            /// Danger Zone: Account Löschen
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white, // Textfarbe auf Rot-Button weiß
                ),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Account wirklich löschen?'),
                      content: const Text(
                          'Dieser Vorgang kann nicht rückgängig gemacht werden.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Abbrechen'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final user = supabase.auth.currentUser;
                            if (user != null) {
                              await supabase.rpc(
                                'delete_user',
                                params: {'uid': user.id},
                              );
                              await supabase.auth.signOut();
                            }
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text(
                            'Löschen',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Account löschen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}