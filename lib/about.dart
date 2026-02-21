import 'package:flutter/material.dart';
import 'variabels.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super .key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Über die App"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppConfig.appname}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Version: ${AppConfig.version}",
            style: TextStyle(fontSize: 16),
           ),
           const SizedBox(height: 16),
           const Text("über die APP....",
           ),
           const SizedBox(height: 16),
           TextButton(
            onPressed: () {
             
            },
            child: const Text("mehr Informationen"),
           )

          ],
        )
        )
    );

  }
} 