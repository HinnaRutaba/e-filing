import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/services/chat_service.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final ChatModel chat;
  final ChatService chatService;
  final int userId;
  final int userDesignationId;
  final String userTitle;
  final void Function(String text) onSendText;
  final VoidCallback onAttachmentPressed;

  const ChatInputBar({
    super.key,
    required this.chat,
    required this.chatService,
    required this.userId,
    required this.userDesignationId,
    required this.userTitle,
    required this.onSendText,
    required this.onAttachmentPressed,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textController = TextEditingController();
  final RecorderController _recorderController = RecorderController();

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
                  : const Icon(Icons.stop, color: Colors.red),
              onPressed: _stoppingRecording ? null : _stopRecording,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
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
        children: [
          // Attachment button 📎
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: AppColors.secondaryLight, width: 0.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.attach_file, color: AppColors.secondary),
              onPressed: widget.onAttachmentPressed,
            ),
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: AppTextField(
              controller: _textController,
              labelText: '',
              hintText: "Type message here...",
              showLabel: false,
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
              : IconButton(
                  icon: const Icon(Icons.mic, color: AppColors.primaryDark),
                  onPressed: _startRecording,
                ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
