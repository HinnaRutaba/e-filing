import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/models/file_details_model.dart';

abstract class ChatInterface extends NetworkBase {
  String fileForChatUrl(int fileId) => '${baseUrl}chat/file/$fileId';
  String getUsersForChatUrl(int userDesgId) =>
      '${baseUrl}chat/users?userDesgID=$userDesgId';

  Future<List<ChatParticipantModel>> getUsersForChat(int? userDesgId);

  Future<FileDetailsModel> getFileDetailsForChat(int? fileId);
}
