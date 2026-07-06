import 'package:efiling_balochistan/config/network/network_base.dart';

abstract class NotificationInterface extends NetworkBase {
  String storeTokenUrl() => '${baseUrl}store-fcm-token';

  Future<void> storeNotificationToken(int desgId, String token);
}
