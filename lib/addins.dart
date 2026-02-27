import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


//Erstellt Widget für Werbe Viedeo
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

  @override// DSGVO Boutton
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
                  const Icon(Icons.play_circle_fill,
                      size: 80, color: Colors.white70),
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