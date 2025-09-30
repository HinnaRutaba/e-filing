import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/services/chat_service.dart';
import 'package:flutter/material.dart';

class VoiceInputBar extends StatefulWidget {
  final ChatModel chat;
  final ChatService chatService;
  final int userId;
  final int userDesignationId;
  final String userTitle;
  final VoidCallback onCancel;

  const VoiceInputBar({
    super.key,
    required this.chat,
    required this.chatService,
    required this.userId,
    required this.userDesignationId,
    required this.userTitle,
    required this.onCancel,
  });

  @override
  State<VoiceInputBar> createState() => _VoiceInputBarState();
}

class _VoiceInputBarState extends State<VoiceInputBar> {
  final RecorderController _recorderController = RecorderController();

  bool _isRecording = false;

  Future<void> _startRecording() async {
    await widget.chatService.startVoiceRecording();
    _recorderController.record(); // start waveform animation
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    await widget.chatService.stopAndSendVoiceMessage(
      chat: widget.chat,
      userId: widget.userId,
      userDesignationId: widget.userDesignationId,
      userTitle: widget.userTitle,
    );
    await _recorderController.stop();
    setState(() => _isRecording = false);
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRecording) {
      return IconButton(
        icon: const Icon(Icons.mic, color: Colors.red),
        onPressed: _startRecording,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.black.withOpacity(0.05),
      child: Row(
        children: [
          Expanded(
            child: AudioWaveforms(
              enableGesture: false,
              size: Size(MediaQuery.of(context).size.width * 0.7, 50),
              recorderController: _recorderController,
              waveStyle: const WaveStyle(
                waveColor: Colors.red,
                extendWaveform: true,
                showMiddleLine: false,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.red),
            onPressed: _stopRecording,
          ),
        ],
      ),
    );
  }
}
