import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'dart:io';
import 'dart:typed_data';

enum FileViewerSize { small, medium, large }

class FileViewer extends StatefulWidget {
  final String filePath;
  final String? fileName;
  final FileViewerSize size;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool showRemoveButton;
  final bool showPlayButton;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const FileViewer({
    super.key,
    required this.filePath,
    this.fileName,
    this.size = FileViewerSize.medium,
    this.onTap,
    this.onRemove,
    this.showRemoveButton = false,
    this.showPlayButton = true,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  static final Map<String, Uint8List?> _videoThumbnailCache = {};

  double get _containerSize {
    switch (widget.size) {
      case FileViewerSize.small:
        return 48;
      case FileViewerSize.medium:
        return 80;
      case FileViewerSize.large:
        return 120;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case FileViewerSize.small:
        return 20;
      case FileViewerSize.medium:
        return 28;
      case FileViewerSize.large:
        return 40;
    }
  }

  double get _textSize {
    switch (widget.size) {
      case FileViewerSize.small:
        return 8;
      case FileViewerSize.medium:
        return 10;
      case FileViewerSize.large:
        return 12;
    }
  }

  String get _fileExtension {
    final fileName = widget.fileName ?? widget.filePath.split('/').last;
    return fileName.toLowerCase().split('.').last;
  }

  bool get _isNetworkFile => widget.filePath.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: _containerSize,
        height: _containerSize,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.secondaryLight.withOpacity(0.3),
          ),
          color: widget.backgroundColor ?? AppColors.cardColor,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              child: Container(
                width: _containerSize,
                height: _containerSize,
                color: widget.backgroundColor ?? AppColors.cardColor,
                child: _buildFileContent(),
              ),
            ),
            if (widget.showRemoveButton && widget.onRemove != null)
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: widget.onRemove,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileContent() {
    // Image files
    if (_isImageFile()) {
      return _buildImageWidget();
    }

    // Video files
    if (_isVideoFile()) {
      return _buildVideoWidget();
    }

    // PDF files
    if (_fileExtension == 'pdf') {
      return _buildIconWidget(
        icon: Icons.picture_as_pdf,
        color: Colors.red,
        label: 'PDF',
      );
    }

    // Document files
    if (_isDocumentFile()) {
      return _buildIconWidget(
        icon: Icons.description,
        color: Colors.blue,
        label: 'Doc',
      );
    }

    // Audio files
    if (_isAudioFile()) {
      return _buildIconWidget(
        icon: Icons.audiotrack,
        color: AppColors.secondary,
        label: 'Audio',
      );
    }

    // Archive files
    if (_isArchiveFile()) {
      return _buildIconWidget(
        icon: Icons.archive,
        color: Colors.orange,
        label: 'Archive',
      );
    }

    // Spreadsheet files
    if (_isSpreadsheetFile()) {
      return _buildIconWidget(
        icon: Icons.table_chart,
        color: Colors.green,
        label: 'Sheet',
      );
    }

    // Presentation files
    if (_isPresentationFile()) {
      return _buildIconWidget(
        icon: Icons.slideshow,
        color: Colors.purple,
        label: 'Slides',
      );
    }

    // Default for other files
    return _buildIconWidget(
      icon: Icons.insert_drive_file,
      color: AppColors.textSecondary,
      label: 'File',
    );
  }

  Widget _buildImageWidget() {
    if (_isNetworkFile) {
      return Image.network(
        widget.filePath,
        fit: BoxFit.cover,
        width: _containerSize,
        height: _containerSize,
        errorBuilder: (context, error, stackTrace) => _buildIconWidget(
          icon: Icons.image,
          color: AppColors.textSecondary,
          label: 'Image',
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return Image.file(
        File(widget.filePath),
        fit: BoxFit.cover,
        width: _containerSize,
        height: _containerSize,
        errorBuilder: (context, error, stackTrace) => _buildIconWidget(
          icon: Icons.image,
          color: AppColors.textSecondary,
          label: 'Image',
        ),
      );
    }
  }

  Widget _buildVideoWidget() {
    return FutureBuilder<Uint8List?>(
      future: _getVideoThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: _containerSize,
                height: _containerSize,
              ),
              if (widget.showPlayButton)
                Container(
                  padding: EdgeInsets.all(_containerSize * 0.1),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(_containerSize * 0.3),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: _iconSize * 0.8,
                  ),
                ),
            ],
          );
        }
        return _buildIconWidget(
          icon: Icons.videocam,
          color: AppColors.secondary,
          label: 'Video',
        );
      },
    );
  }

  Widget _buildIconWidget({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: _iconSize),
          if (widget.size != FileViewerSize.small) ...[
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: _textSize,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<Uint8List?> _getVideoThumbnail() async {
    final cacheKey = widget.filePath;

    if (_videoThumbnailCache.containsKey(cacheKey)) {
      return _videoThumbnailCache[cacheKey];
    }

    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: widget.filePath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: _containerSize.toInt(),
        maxHeight: _containerSize.toInt(),
        quality: 75,
      );

      _videoThumbnailCache[cacheKey] = thumbnail;
      return thumbnail;
    } catch (e) {
      print('Error generating video thumbnail: $e');
      return null;
    }
  }

  bool _isImageFile() {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg']
        .contains(_fileExtension);
  }

  bool _isVideoFile() {
    return ['mp4', 'mov', 'avi', 'mkv', '3gp', 'webm', 'flv', 'wmv']
        .contains(_fileExtension);
  }

  bool _isDocumentFile() {
    return ['doc', 'docx', 'txt', 'rtf', 'odt'].contains(_fileExtension);
  }

  bool _isAudioFile() {
    return ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac', 'wma']
        .contains(_fileExtension);
  }

  bool _isArchiveFile() {
    return ['zip', 'rar', '7z', 'tar', 'gz', 'bz2'].contains(_fileExtension);
  }

  bool _isSpreadsheetFile() {
    return ['xls', 'xlsx', 'csv', 'ods'].contains(_fileExtension);
  }

  bool _isPresentationFile() {
    return ['ppt', 'pptx', 'odp'].contains(_fileExtension);
  }

  static void clearVideoThumbnailCache() {
    _videoThumbnailCache.clear();
  }
}

// Helper widget for grid/list views
class FileGrid extends StatelessWidget {
  final List<String> filePaths;
  final List<String>? fileNames;
  final FileViewerSize size;
  final int crossAxisCount;
  final void Function(String filePath, int index)? onFileTap;
  final void Function(int index)? onFileRemove;
  final bool showRemoveButtons;

  const FileGrid({
    super.key,
    required this.filePaths,
    this.fileNames,
    this.size = FileViewerSize.medium,
    this.crossAxisCount = 3,
    this.onFileTap,
    this.onFileRemove,
    this.showRemoveButtons = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: filePaths.length,
      itemBuilder: (context, index) {
        return FileViewer(
          filePath: filePaths[index],
          fileName: fileNames?[index],
          size: size,
          onTap: () => onFileTap?.call(filePaths[index], index),
          onRemove: onFileRemove != null ? () => onFileRemove!(index) : null,
          showRemoveButton: showRemoveButtons,
        );
      },
    );
  }
}

// Helper widget for horizontal lists
class FileHorizontalList extends StatelessWidget {
  final List<String> filePaths;
  final List<String>? fileNames;
  final FileViewerSize size;
  final void Function(String filePath, int index)? onFileTap;
  final void Function(int index)? onFileRemove;
  final bool showRemoveButtons;
  final double? height;

  const FileHorizontalList({
    super.key,
    required this.filePaths,
    this.fileNames,
    this.size = FileViewerSize.medium,
    this.onFileTap,
    this.onFileRemove,
    this.showRemoveButtons = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final containerSize = size == FileViewerSize.small
        ? 48.0
        : size == FileViewerSize.medium
            ? 80.0
            : 120.0;

    return SizedBox(
      height: height ?? containerSize,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filePaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FileViewer(
              filePath: filePaths[index],
              fileName: fileNames?[index],
              size: size,
              onTap: () => onFileTap?.call(filePaths[index], index),
              onRemove:
                  onFileRemove != null ? () => onFileRemove!(index) : null,
              showRemoveButton: showRemoveButtons,
            ),
          );
        },
      ),
    );
  }
}
