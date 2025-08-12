import 'dart:io';

import 'package:efiling_balochistan/views/screens/splash_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as webview_flutter_android;

class AdminWebView extends StatefulWidget {
  const AdminWebView({super.key});

  @override
  State<AdminWebView> createState() => _AdminWebViewState();
}

class _AdminWebViewState extends State<AdminWebView> {
  late WebViewController controller;
  int loadingProgress = 0;
  int pageProgress = 0;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              if (loadingProgress < 100) {
                loadingProgress = progress;
              } else {
                pageProgress = progress;
              }
            });
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {
            print(
                "ERRR______${error.response?.statusCode}_____${error.response?.headers}");
          },
          onUrlChange: (url) {
            setState(() {
              pageProgress = 0;
            });
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //   return NavigationDecision.prevent;
            // }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse("https://efiling.balochistan.gob.pk/"));
    initFilePicker();
    super.initState();
  }

  initFilePicker() async {
    if (Platform.isAndroid) {
      final androidController = (controller.platform
          as webview_flutter_android.AndroidWebViewController);
      await androidController.setOnShowFileSelector(_androidFilePicker);
    }
  }

  Future<List<String>> _androidFilePicker(
      webview_flutter_android.FileSelectorParams params) async {
    if (params.acceptTypes.any((type) => type == 'image/*')) {
      final picker = image_picker.ImagePicker();
      final photo =
          await picker.pickImage(source: image_picker.ImageSource.camera);

      if (photo == null) {
        return [];
      }
      return [Uri.file(photo.path).toString()];
    } else if (params.acceptTypes.any((type) => type == 'video/*')) {
      final picker = image_picker.ImagePicker();
      final vidFile = await picker.pickVideo(
          source: ImageSource.camera, maxDuration: const Duration(seconds: 10));
      if (vidFile == null) {
        return [];
      }
      return [Uri.file(vidFile.path).toString()];
    } else {
      try {
        if (params.mode == webview_flutter_android.FileSelectorMode.open) {
          final attachments = await FilePicker.platform.pickFiles(
              allowMultiple: false,
              type: FileType.custom,
              allowedExtensions: ['pdf'],
              allowCompression: true);
          if (attachments == null) return [];

          return attachments.files
              .where((element) => element.path != null)
              .map((e) => File(e.path!).uri.toString())
              .toList();
        } else {
          final attachment = await FilePicker.platform.pickFiles();
          if (attachment == null) return [];
          File file = File(attachment.files.single.path!);
          return [file.uri.toString()];
        }
      } catch (e) {
        return [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('webview_flutter_plus Example'),
      // ),
      body: loadingProgress < 100
          ? const SplashScreen(navigate: false)
          : Stack(
              children: [
                WebViewWidget(controller: controller)
                    .animate()
                    .fade(duration: 900.milliseconds),
                if (pageProgress < 100)
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      height: 6,
                      width: MediaQuery.sizeOf(context).width,
                      child: LinearProgressIndicator(
                        value: pageProgress.toDouble(),
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
