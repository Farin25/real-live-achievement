import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_SessionManager.dart';
import 'package:intl/intl.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  Map<String, dynamic>? profile;
  String formatDate(String? date) {
  if (date == null) return "";

  final parsed = DateTime.parse(date);
  return DateFormat('dd.MM.yyyy').format(parsed);
}

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _birthdateController = TextEditingController();
  


  Future<void> _loadProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;


    if (user != null) {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        profile = data;
        _firstNameController.text = data['first_name'] ?? '';
        _lastNameController.text = data['last_name'] ?? '';
        _usernameController.text = data['username'] ?? '';
        _birthdateController.text = data['birthdate'] ?? '';

      });
    }
  }

  Future<void> _saveProfile() async { 
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    if (user ==  null) return;

    await supabase.from('profiles').update({
      'first_name':_firstNameController.text,
      'last_name':_lastNameController.text,
      'username':_usernameController.text,
      'birthdate': _birthdateController.text,
    }).eq('id', user.id);
  }

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
          children: [

            /// PROFILE HEADER
            profile == null
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            Theme.of(context).primaryColor,
                        child: const Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile!['username'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${profile!['first_name'] ?? ''} ${profile!['last_name'] ?? ''}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

            const SizedBox(height: 30),
            // Profiel bzw. Acount Settings:

            Expanded(
              child: profile == null
              ? const SizedBox()
              : ListView(
                children: [

                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Vornahme',
                  ),
                ),
                const SizedBox(height: 15,),
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nachname',
                  ),
                ),
                const SizedBox(height: 15,),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'username ', 
                  ),
                ),
                const SizedBox(height: 15,),
                TextField(
                  controller: _birthdateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText:'Geburtsdatum',
                   prefix: Icon(Icons.calendar_today),
                   border: OutlineInputBorder(), 
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                     context: context,
                     initialDate: DateTime.now(),
                     firstDate: DateTime(1900),
                     lastDate: DateTime.now(),);
                  },
                ),
                const SizedBox(height: 25,),

                ElevatedButton(onPressed: _saveProfile, child: const Text('änderungen Speichern'),
                )
              ],
            ),
           ),
                     if (profile != null) ...[
            Text(
              "Letzte änderung: ${formatDate(profile!['updated_at'])}",
              style: TextStyle(color: Colors.grey[600]),
           ),
           const SizedBox(height: 5,),

           Text(
            "Account erstellt: ${formatDate(profile!['created_at'])}",
            style: TextStyle(color: Colors.grey[600]),
           ),
          const SizedBox(height: 10,),
           ],

           

            /// LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await UserSessionmanager.logout();
                },
                child: const Text('Abmelden'),
              ),
            ),

            const SizedBox(height: 12),

            /// ACCOUNT LÖSCHEN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Account wirklich löschen?'),
                      content: const Text(
                        'Dieser Vorgang kann nicht rückgängig gemacht werden.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Abbrechen'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final user =
                                supabase.auth.currentUser;

                            if (user != null) {
                              await supabase.rpc(
                                'delete_user',
                                params: {'uid': user.id},
                              );
                              await supabase.auth.signOut();
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Löschen',
                            style:
                                TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(height: 15,),

                      ],
                    ),
                  );
                },
                child: const Text('Account löschen'),
              ),
            ),

         ]
        ),
      ),
    );
   }
  }