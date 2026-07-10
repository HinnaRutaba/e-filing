import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:efiling_balochistan/controllers/local_storage_controller.dart';

class PdfViewer extends StatefulWidget {
  final String? url;
  final String? title;
  final List<Widget>? actions;
  final bool fullScreen;
  final bool showPageNumber;

  const PdfViewer({
    super.key,
    required this.url,
    this.title,
    this.actions,
    this.fullScreen = true,
    this.showPageNumber = true,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final PdfViewerController pdfViewerController = PdfViewerController();
  final pdfrx.PdfViewerController _pdfrxController =
      pdfrx.PdfViewerController();
  String? _errorMessage;
  Map<String, String>? _headers;
  int? _currentPage;
  int? _totalPages;

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

  bool get _isLocalFile =>
      widget.url != null && !widget.url!.startsWith('http');

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
                : _isLocalFile
                ? SfPdfViewer.file(
                    File(widget.url!),
                    controller: pdfViewerController,
                    onDocumentLoadFailed:
                        (PdfDocumentLoadFailedDetails details) {
                          setState(() {
                            _errorMessage =
                                '${details.error}\n\n${details.description}';
                          });
                        },
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
        : Stack(
            children: [
              pdfrx.PdfViewer.uri(
                Uri.parse(widget.url ?? ""),
                controller: _pdfrxController,
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
                  onViewerReady: (document, controller) {
                    if (mounted) {
                      setState(() => _totalPages = document.pages.length);
                    }
                  },
                  onPageChanged: (pageNumber) {
                    if (mounted) setState(() => _currentPage = pageNumber);
                  },
                ),
              ),
              if (widget.showPageNumber && _currentPage != null && _totalPages != null)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_currentPage/$_totalPages',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          );
  }
}
