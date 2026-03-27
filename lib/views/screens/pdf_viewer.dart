import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;

class PdfViewer extends StatefulWidget {
  final String? url;
  final String? title;
  final List<Widget>? actions;
  final bool fullScreen;

  const PdfViewer(
      {super.key,
      required this.url,
      this.title,
      this.actions,
      this.fullScreen = true});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final PdfViewerController pdfViewerController = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    return widget.fullScreen
        ? Scaffold(
            appBar: AppBar(
              title: Text(widget.title ?? "View File"),
              centerTitle: true,
              titleSpacing: 0,
              actions: widget.actions,
            ),
            body: widget.url == null
                ? const Center(child: Text("Attachment url is invalid"))
                : SfPdfViewer.network(
                    widget.url!,
                    controller: pdfViewerController,
                  ),
          )
        : pdfrx.PdfViewer.uri(
            Uri.parse(
                "https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf"),
          );
  }
}
