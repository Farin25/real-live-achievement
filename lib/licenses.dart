import 'package:flutter/material.dart';
import 'variabels.dart';
import 'navbar.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Open Source Lizenzen"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Lizenz anzeigen"),
          onPressed: () {
            showLicensePage(
              context: context,
              applicationName: "${AppConfig.appname}",
              applicationVersion: "${AppConfig.version}",
           );
          }
        ),
      ),
      bottomNavigationBar: Navbar(),
    );
  }
}