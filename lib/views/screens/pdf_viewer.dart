import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatefulWidget {
  final String? url;
  final String? title;
  final List<Widget>? actions;
  const PdfViewer({super.key, required this.url, this.title, this.actions});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final PdfViewerController pdfViewerController = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "View File"),
        centerTitle: true,
        titleSpacing: 0,
        actions: widget.actions,
      ),
      body: widget.url == null
          ? const Center(child: Text("Attachment url is invalid"))
          : SfPdfViewer.network(widget.url!, controller: pdfViewerController),
    );
  }
}
