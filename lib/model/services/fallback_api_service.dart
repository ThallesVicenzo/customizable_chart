import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:customizable_chart/viewmodel/services/secure_storage/secure_storage.dart';
import 'package:customizable_chart/viewmodel/services/secure_storage/keys/secure_storage_keys.dart';

abstract class FallbackApiService {
  static const int maxUsageCount = 3;

  Future<int> getCurrentUsageCount();

  Future<void> incrementUsageCount();

  Future<bool> canUseFallbackApi();

  Future<int> getRemainingUsageCount();

  String? getFallbackApiKey();

  Future<String?> getUserApiKey();

  Future<void> resetUsageCount();
}

class FallbackApiServiceImplementation implements FallbackApiService {
  final SecureStorage _secureStorage;

  FallbackApiServiceImplementation(this._secureStorage);

  @override
  Future<int> getCurrentUsageCount() async {
    final countString = await _secureStorage.read(
      key: SecureStorageKeys.fallbackApiUsageCount.key,
    );
    return int.tryParse(countString ?? '0') ?? 0;
  }

  @override
  Future<void> incrementUsageCount() async {
    final currentCount = await getCurrentUsageCount();
    final newCount = currentCount + 1;
    await _secureStorage.write(
      key: SecureStorageKeys.fallbackApiUsageCount.key,
      value: newCount.toString(),
    );
  }

  @override
  Future<bool> canUseFallbackApi() async {
    final currentCount = await getCurrentUsageCount();
    final canUse = currentCount < FallbackApiService.maxUsageCount;
    log(
      'Fallback API usage check - current: $currentCount, max: ${FallbackApiService.maxUsageCount}, can use: $canUse',
      name: 'FallbackApiService',
    );
    return canUse;
  }

  @override
  Future<int> getRemainingUsageCount() async {
    final currentCount = await getCurrentUsageCount();
    return FallbackApiService.maxUsageCount - currentCount;
  }

  @override
  String? getFallbackApiKey() {
    final apiKey = dotenv.env['FALLBACK_OPENAI_API_KEY'];
    log(
      'Fallback API key status: ${apiKey != null && apiKey.isNotEmpty ? "Present (${apiKey.length} chars)" : "Not found"}',
      name: 'FallbackApiService',
    );
    return apiKey;
  }

  @override
  Future<String?> getUserApiKey() async {
    return await _secureStorage.read(key: SecureStorageKeys.openaiApiKey.key);
  }

  @override
  Future<void> resetUsageCount() async {
    log('Resetting fallback API usage count', name: 'FallbackApiService');
    await _secureStorage.delete(
      key: SecureStorageKeys.fallbackApiUsageCount.key,
    );
    final newCount = await getCurrentUsageCount();
    log('Usage count after reset: $newCount', name: 'FallbackApiService');
  }
}
