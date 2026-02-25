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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            const Text(
              'Hier kommen später deine Account Settings rein.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),

            Column(
              children: [

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

                /// Danger Zone : Acount Löschen
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
                              onPressed: () {
                                Navigator.pop(context);
                              },
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

                                Navigator.pop(context);
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
          ],
        ),
      ),
    );
  }
}