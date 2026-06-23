import 'package:efiling_balochistan/models/user_model.dart';

class TokenModel {
  final UserModel? user;
  final String? token;

  TokenModel({required this.user, required this.token});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    try {
      return TokenModel(
        user: UserModel.fromJson(json[TokenSchema.user]),
        token: json[TokenSchema.token],
      );
    } catch (e) {
    
      return TokenModel(user: UserModel(), token: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      TokenSchema.user: user?.toJson(),
      TokenSchema.token: token,
    };
  }
}

class TokenSchema {
  static const String user = 'user';
  static const String token = 'token';
}
