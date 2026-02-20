import 'package:flutter/material.dart';

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
              applicationName: "Mark UP",
              applicationVersion: "BETA 0.5",
           );
          }
        ),
      ),
    );
  }
}