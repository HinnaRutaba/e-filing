import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/utils/file_picker_service.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'dart:typed_data';

class ChatInputBar extends StatefulWidget {
  final ChatModel chat;
  final ChatService chatService;
  final int userId;
  final int userDesignationId;
  final String userTitle;
  final void Function(String text) onSendText;

  const ChatInputBar({
    super.key,
    required this.chat,
    required this.chatService,
    required this.userId,
    required this.userDesignationId,
    required this.userTitle,
    required this.onSendText,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textController = TextEditingController();
  final RecorderController _recorderController = RecorderController();
  final FilePickerService _filePickerService = FilePickerService();
  List<XFile> files = [];
  Map<String, Uint8List?> videoThumbnails = {};

  bool _isRecording = false;
  bool _stoppingRecording = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {}); // rebuild to toggle send/mic button
  }

  Future<void> _startRecording() async {
    await widget.chatService.startVoiceRecording();
    _recorderController.record();
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    try {
      setState(() {
        _stoppingRecording = true;
      });
      await widget.chatService.stopAndSendVoiceMessage(
        chat: widget.chat,
        userId: widget.userId,
        userDesignationId: widget.userDesignationId,
        userTitle: widget.userTitle,
      );
      await _recorderController.stop();
      setState(() {
        _isRecording = false;
        _stoppingRecording = false;
      });
    } catch (e, s) {
      print("Stop Recording Error_____${e}_____$s");
    }
  }

  Future<void> _cancelRecording() async {
    await widget.chatService.cancelVoiceRecording();
    await _recorderController.stop();
    setState(() => _isRecording = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isRecording) {
      // Show waveform while recording
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //color: AppColors.cardColor,
        child: Row(
          children: [
            Expanded(
              child: AudioWaveforms(
                enableGesture: false,
                size: Size(MediaQuery.of(context).size.width * 0.7, 50),
                recorderController: _recorderController,
                waveStyle: const WaveStyle(
                  waveColor: AppColors.secondary,
                  extendWaveform: true,
                  showMiddleLine: false,
                ),
              ),
            ),
            IconButton(
              icon: _stoppingRecording
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_outlined, color: AppColors.secondary),
              onPressed: _stoppingRecording ? null : _stopRecording,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[700]),
              onPressed: _cancelRecording,
            ),
          ],
        ),
      );
    }

    // Default input bar
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      // color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attachment button 📎

          InkWell(
            onTap: () async {
              files = await _filePickerService.pickMedia();
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(color: AppColors.secondaryLight, width: 0.7),
              ),
              child: const Icon(Icons.attach_file, color: AppColors.secondary),
            ),
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _textController,
                  labelText: '',
                  hintText: "Type message here...",
                  showLabel: false,
                ),
                // File preview horizontal scroll
                if (files.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        return _buildFilePreview(files[index], index);
                      },
                    ),
                  ),
                ]
              ],
            ),
          ),

          _textController.text.trim().isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primaryDark),
                  onPressed: () {
                    final text = _textController.text.trim();
                    if (text.isNotEmpty) {
                      widget.onSendText(text);
                      _textController.clear();
                    }
                  },
                )
              : const SizedBox.shrink(),
          IconButton(
            icon: const Icon(Icons.mic, color: AppColors.secondary),
            onPressed: _startRecording,
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(XFile file, int index) {
    final fileName = file.name.toLowerCase();
    final fileExtension = fileName.split('.').last;

    return Container(
      width: 48,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondaryLight.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: AppColors.cardColor,
              child: _getFileWidget(file, fileExtension),
            ),
          ),
          // Remove button
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _removeFile(index),
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
    );
  }

  Widget _getFileWidget(XFile file, String fileExtension) {
    // Image files
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(fileExtension)) {
      return Image.file(
        File(file.path),
        fit: BoxFit.cover,
        width: 48,
        height: 48,
      );
    }

    // Video files
    if (['mp4', 'mov', 'avi', 'mkv', '3gp', 'webm'].contains(fileExtension)) {
      return FutureBuilder<Uint8List?>(
        future: _getVideoThumbnail(file.path),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  width: 70,
                  height: 80,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            );
          }
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam, color: AppColors.secondary, size: 24),
                SizedBox(height: 4),
                Text('Video', style: TextStyle(fontSize: 10)),
              ],
            ),
          );
        },
      );
    }

    // PDF files
    if (fileExtension == 'pdf') {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
            SizedBox(height: 4),
            Text('PDF', style: TextStyle(fontSize: 10)),
          ],
        ),
      );
    }

    // Document files
    if (['doc', 'docx', 'txt', 'rtf'].contains(fileExtension)) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, color: Colors.blue, size: 24),
            SizedBox(height: 4),
            Text('Doc', style: TextStyle(fontSize: 10)),
          ],
        ),
      );
    }

    // Audio files
    if (['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(fileExtension)) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.audiotrack, color: AppColors.secondary, size: 24),
            SizedBox(height: 4),
            Text('Audio', style: TextStyle(fontSize: 10)),
          ],
        ),
      );
    }

    // Default for other files
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file,
              color: AppColors.textSecondary, size: 24),
          SizedBox(height: 4),
          Text('File', style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Future<Uint8List?> _getVideoThumbnail(String videoPath) async {
    if (videoThumbnails.containsKey(videoPath)) {
      return videoThumbnails[videoPath];
    }

    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 70,
        maxHeight: 80,
        quality: 75,
      );

      videoThumbnails[videoPath] = thumbnail;
      return thumbnail;
    } catch (e) {
      print('Error generating video thumbnail: $e');
      return null;
    }
  }

  void _removeFile(int index) {
    setState(() {
      final removedFile = files[index];
      files.removeAt(index);
      // Clean up video thumbnail cache
      videoThumbnails.remove(removedFile.path);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
