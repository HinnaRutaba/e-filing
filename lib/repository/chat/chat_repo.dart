import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/models/file_details_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_interface.dart';

class ChatRepo extends ChatInterface {
  @override
  Future<FileDetailsModel> getFileDetailsForChat(int? fileId) async {
    try {
      if (fileId == null) {
        throw Exception("File ID is required to fetch file details");
      }
      Map<String, dynamic> data = await dioClient.get(
        url: fileForChatUrl(fileId),
        options: await options(authRequired: true),
      );

      return FileDetailsModel.fromJsonPending(data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ChatParticipantModel>> getUsersForChat(int? userDesgId) async {
    try {
      if (userDesgId == null) {
        throw Exception("Designation ID is required to fetch users");
      }
      Map<String, dynamic> data = await dioClient.get(
        url: getUsersForChatUrl(userDesgId),
        options: await options(authRequired: true),
      );
      return data['data']!
          .map<ChatParticipantModel>(
            (e) => ChatParticipantModel.fromParticipantEndpoint(e),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
