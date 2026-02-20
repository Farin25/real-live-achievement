import 'package:flutter/material.dart';

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
            const Text(
              "Mark UP",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Version: BETA 0.5",
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