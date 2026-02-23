import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


// Krasses Webeviedeo
class VimeoVideo extends StatefulWidget {
  const VimeoVideo({super.key});

  @override
  State<VimeoVideo> createState() => _VimeoVideoState();
}

class _VimeoVideoState extends State<VimeoVideo> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
        <html>
          <body style="margin:0;">
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
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: WebViewWidget(controller: controller),
    );
  }
}