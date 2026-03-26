import 'package:flutter/material.dart';
import 'settings.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LicensePage(
        applicationName: AppConfig.appname,
        applicationVersion: AppConfig.version,
      ),
      //  bottomNavigationBar: Navbar(),// mal schaune ob drin alssen oder rausnehmen
    );
  }
}
