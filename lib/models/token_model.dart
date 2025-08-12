class TokenModel {
  final int userId;
  final String token;

  TokenModel({required this.userId, required this.token});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    try {
      return TokenModel(
        userId: json[TokenSchema.userId],
        token: json[TokenSchema.token],
      );
    } catch (e, s) {
      print("Token Error_____${e}_____$s");
      return TokenModel(userId: 0, token: '');
    }
  }

  factory TokenModel.fromLogin(Map<String, dynamic> json) {
    try {
      return TokenModel(
        userId: json.containsKey(TokenSchema.user)
            ? json[TokenSchema.user][TokenSchema.id]
            : 0,
        token: json[TokenSchema.token],
      );
    } catch (e, s) {
      print("Token Error_____${e}_____$s");
      return TokenModel(userId: 0, token: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      TokenSchema.userId: userId,
      TokenSchema.token: token,
    };
  }
}

class TokenSchema {
  static const String user = 'user';
  static const String userId = 'user_id';
  static const String token = 'token';
  static const String id = 'id';
}
