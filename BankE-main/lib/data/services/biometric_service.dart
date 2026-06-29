import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to log in to your banking account',
        biometricOnly: false,
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: 'bio_email', value: email);
    await _secureStorage.write(key: 'bio_password', value: password);
    await _secureStorage.write(key: 'bio_enabled', value: 'true');
  }

  Future<Map<String, String>?> getCredentials() async {
    final isEnabled = await _secureStorage.read(key: 'bio_enabled');
    if (isEnabled == 'true') {
      final email = await _secureStorage.read(key: 'bio_email');
      final password = await _secureStorage.read(key: 'bio_password');
      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
    }
    return null;
  }

  Future<void> disableBiometrics() async {
    await _secureStorage.write(key: 'bio_enabled', value: 'false');
  }

  Future<bool> isBiometricsEnabled() async {
    final isEnabled = await _secureStorage.read(key: 'bio_enabled');
    return isEnabled == 'true';
  }
}
