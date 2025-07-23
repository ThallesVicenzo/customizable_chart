import 'package:customizable_chart/viewmodel/services/secure_storage/secure_storage.dart';
import 'package:customizable_chart/viewmodel/services/secure_storage/keys/secure_storage_keys.dart';
import 'package:customizable_chart/injector.dart';

const String endpoint = 'https://api.openai.com/v1/chat/completions';

Future<String?> get authToken async {
  final secureStorage = sl<SecureStorage>();
  return await secureStorage.read(key: SecureStorageKeys.openaiApiKey.key);
}
