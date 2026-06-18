import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:efiling_balochistan/controllers/local_storage_controller.dart';

class PdfViewer extends StatefulWidget {
  final String? url;
  final String? title;
  final List<Widget>? actions;
  final bool fullScreen;

  const PdfViewer({
    super.key,
    required this.url,
    this.title,
    this.actions,
    this.fullScreen = true,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final PdfViewerController pdfViewerController = PdfViewerController();
  String? _errorMessage;
  Map<String, String>? _headers;

  @override
  void initState() {
    super.initState();
    _loadHeaders();
  }

  Future<void> _loadHeaders() async {
    final token = await LocalStorageController().getToken();
    final headers = <String, String>{"Accept": "application/json"};
    if (token != null) {
      headers["Authorization"] = "Bearer ${token.token}";
    }
    if (mounted) {
      setState(() => _headers = headers);
    }
  }

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
                : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SelectableText(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                : _headers == null
                ? const Center(child: CircularProgressIndicator())
                : SfPdfViewer.network(
                    widget.url!,
                    controller: pdfViewerController,
                    headers: _headers,
                    onDocumentLoadFailed:
                        (PdfDocumentLoadFailedDetails details) {
                          setState(() {
                            _errorMessage =
                                '${details.error}\n\n${details.description}';
                          });
                        },
                  ),
          )
        : pdfrx.PdfViewer.uri(
            Uri.parse(widget.url ?? ""),
            params: pdfrx.PdfViewerParams(
              errorBannerBuilder: (context, error, stackTrace, child) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SelectableText(
                      error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              },
            ),
          );
  }
}
