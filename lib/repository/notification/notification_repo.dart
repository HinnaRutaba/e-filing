import 'package:efiling_balochistan/repository/notification/notification_interface.dart';

class NotificationRepo extends NotificationInterface {
  @override
  Future<void> storeNotificationToken(int? desgId, String? token) async {
    try {
      if (desgId == null) {
        throw Exception('Designation ID is required to dispose off');
      }
      if (token == null) {
        throw Exception('Tokenis required to dispose off');
      }
      await dioClient.post(
        url: storeTokenUrl(),
        options: await options(authRequired: true),
        data: {'user_desg_id': desgId, 'token': token},
      );
    } catch (e) {
      rethrow;
    }
  }
}
