import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication auth = LocalAuthentication();

  List<BiometricType> _availableBiometrics = [];
  bool get showBiometric =>
      _availableBiometrics.contains(BiometricType.fingerprint) ||
      _availableBiometrics.contains(BiometricType.face);

  Future<void> init() async {
    _availableBiometrics = await auth.getAvailableBiometrics();
  }

  Future<bool> authenticate() async {
    try {
      bool isAuthenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to proceed',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return isAuthenticated;
    } catch (e, s) {
      print("AUTH ERROR_______${e}_____$s");
      return false;
    }
  }
}
