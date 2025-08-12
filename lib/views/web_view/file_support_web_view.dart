import 'dart:convert';
import 'dart:io';

import 'package:efiling_balochistan/views/screens/splash_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InAppWebViewWithFileUpload extends StatefulWidget {
  const InAppWebViewWithFileUpload({super.key});

  @override
  State<InAppWebViewWithFileUpload> createState() =>
      _InAppWebViewWithFileUploadState();
}

class _InAppWebViewWithFileUploadState
    extends State<InAppWebViewWithFileUpload> {
  InAppWebViewController? webViewController;
  int loadingProgress = 0;
  bool init = false;
  bool reloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri("https://efiling.balochistan.gob.pk/"),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
            ),
            onOverScrolled: (controller, x, y, cx, cy) async {
              if (x == 0 && y == 0 && !reloading) {
                reloading = true;
                await webViewController?.reload();
                reloading = false;
              }
            },
            onWebViewCreated: (controller) {
              webViewController = controller;

              // Add JS bridge handler
              controller.addJavaScriptHandler(
                handlerName: 'pickFile',
                callback: (args) async {
                  final result = await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                      allowCompression: true);

                  if (result != null && result.files.single.path != null) {
                    final file = File(result.files.single.path!);
                    final bytes = await file.readAsBytes();
                    final base64Data = base64Encode(bytes);

                    return {
                      'base64': base64Data,
                      'name': result.files.single.name,
                      'type': result.files.single.identifier ??
                          'application/octet-stream',
                    };
                  }

                  return null;
                },
              );
            },
            onLoadStart: (controller, url) {
              setState(() {
                loadingProgress = 0;
              });
            },
            onLoadStop: (controller, url) async {
              // Inject JS to catch input[type=file]
              await controller.evaluateJavascript(source: """
                document.querySelectorAll('input[type="application/pdf"]').forEach(input => {
                  input.addEventListener('click', function(e) {
                    e.preventDefault();
                    window.flutter_inappwebview.callHandler('pickFile').then(result => {
                      if (result) {
                        const byteCharacters = atob(result.base64);
                        const byteNumbers = new Array(byteCharacters.length);
                        for (let i = 0; i < byteCharacters.length; i++) {
                          byteNumbers[i] = byteCharacters.charCodeAt(i);
                        }
                        const byteArray = new Uint8Array(byteNumbers);
                        const blob = new Blob([byteArray], {type: result.type});
                        const file = new File([blob], result.name, {type: result.type});
    
                        const dataTransfer = new DataTransfer();
                        dataTransfer.items.add(file);
                        input.files = dataTransfer.files;
    
                        const event = new Event('change', { bubbles: true });
                        input.dispatchEvent(event);
                      }
                    });
                  });
                });
              """);

              setState(() {
                init = true;
                loadingProgress = 100;
              });
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                loadingProgress = progress;
              });
            },
          ).animate().fade(duration: 900.milliseconds),
          if (!init && loadingProgress < 100)
            const SplashScreen(navigate: false),
          if (loadingProgress < 100)
            Positioned(
              top: 0,
              child: SizedBox(
                height: 6,
                width: MediaQuery.of(context).size.width,
                child: LinearProgressIndicator(
                  value: loadingProgress / 100,
                  color: Colors.blue,
                  backgroundColor: Colors.blue.shade100,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
