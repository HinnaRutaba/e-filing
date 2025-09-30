import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatefulWidget {
  final String? url;
  const PdfViewer({super.key, required this.url});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  int pages = 0;
  bool isReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.headlineSmall("View Attachment"),
        backgroundColor: AppColors.background,
        centerTitle: false,
        leading: const SizedBox.shrink(),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () {
              RouteHelper.pop();
            },
          ),
        ],
      ),
      body: widget.url == null
          ? Center(
              child: AppText.titleSmall("Attachment url is invalid"),
            )
          : SfPdfViewer.network(widget.url!),
    );
  }
}
