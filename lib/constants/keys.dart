class Keys {
  static final Keys _instance = Keys._internal();

  factory Keys() {
    return _instance;
  }

  Keys._internal();

  static String openAIKey = ''; //Must get initialised on app start
}
