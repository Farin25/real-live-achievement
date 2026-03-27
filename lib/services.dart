//Services.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class UserLocalServices {
  static Future<void> saveUserProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String birthdate,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('first_name', firstName);
    await prefs.setString('last_name', lastName);
    await prefs.setString('username', username);
    await prefs.setString('birthdate', birthdate);
  }

  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('first_name');
    await prefs.remove('last_name');
    await prefs.remove('username');
    await prefs.remove('birthdate');
  }

  // Cache Löschen
  static Future<void> clearAchievementCache() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('cached_achievements');
    //Debug Ausgabe
    print("Achievement Cache gelöscht");
  }
}

//----------------------------------
//----------Vimeo Viedeo------------
//----------------------------------

class VimeoVideo extends StatefulWidget {
  const VimeoVideo({super.key});

  @override
  State<VimeoVideo> createState() => _VimeoVideoState();
}

// Lädt Vimeo Viedeo im iframe
class _VimeoVideoState extends State<VimeoVideo> {
  WebViewController? controller;
  bool _accepted = false;

  void _loadVideo() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
        <html>
          <body style="margin:0; background:black;">
            <iframe 
              src="https://player.vimeo.com/video/1167330665"
              width="100%" 
              height="100%" 
              frameborder="0"
              allow="autoplay; fullscreen"
              allowfullscreen>
            </iframe>
          </body>
        </html>
      ''');

    setState(() {
      _accepted = true;
    });
  }

  @override // DSGVO Boutton
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _accepted
          ? WebViewWidget(controller: controller!)
          : Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_fill,
                    size: 80,
                    color: Colors.white70,
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        const Text(
                          "Externer Inhalt von Vimeo\nDurch Klick wird eine Verbindung zu Vimeo hergestellt.",
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadVideo,
                          child: const Text("Video laden"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
