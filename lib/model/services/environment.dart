import 'dart:developer';
import 'package:customizable_chart/utils/secure_storage/secure_storage.dart';
import 'package:customizable_chart/utils/secure_storage/keys/secure_storage_keys.dart';
import 'package:customizable_chart/model/services/fallback_api_service.dart';

const String endpoint = 'https://api.openai.com/v1/chat/completions';

abstract class EnvironmentService {
  Future<String?> getAuthToken();

  Future<Map<String, dynamic>> getTokenUsageInfo();
}

class EnvironmentServiceImplementation implements EnvironmentService {
  final SecureStorage _secureStorage;
  final FallbackApiService _fallbackApiService;

  EnvironmentServiceImplementation(
    this._secureStorage,
    this._fallbackApiService,
  );

  @override
  Future<String?> getAuthToken() async {
    log('Getting auth token...', name: 'EnvironmentService');

    final userToken = await _secureStorage.read(
      key: SecureStorageKeys.openaiApiKey.key,
    );

    log(
      'User token status: ${userToken != null && userToken.isNotEmpty ? "Present (${userToken.length} chars)" : "Not found"}',
      name: 'EnvironmentService',
    );

    if (userToken != null && userToken.isNotEmpty) {
      return userToken;
    }

    log('Checking fallback API availability...', name: 'EnvironmentService');
    final canUseFallback = await _fallbackApiService.canUseFallbackApi();
    log('Can use fallback: $canUseFallback', name: 'EnvironmentService');

    if (canUseFallback) {
      final fallbackToken = _fallbackApiService.getFallbackApiKey();
      log(
        'Fallback token status: ${fallbackToken != null && fallbackToken.isNotEmpty ? "Present (${fallbackToken.length} chars)" : "Not found"}',
        name: 'EnvironmentService',
      );

      if (fallbackToken != null && fallbackToken.isNotEmpty) {
        await _fallbackApiService.incrementUsageCount();
        return fallbackToken;
      }
    }

    log('No auth token available', name: 'EnvironmentService');
    return null;
  }

  @override
  Future<Map<String, dynamic>> getTokenUsageInfo() async {
    final userToken = await _secureStorage.read(
      key: SecureStorageKeys.openaiApiKey.key,
    );
    final hasUserToken = userToken != null && userToken.isNotEmpty;

    final remainingFallbackUses =
        await _fallbackApiService.getRemainingUsageCount();
    final canUseFallback = await _fallbackApiService.canUseFallbackApi();

    return {
      'hasUserToken': hasUserToken,
      'remainingFallbackUses': remainingFallbackUses,
      'canUseFallback': canUseFallback,
      'totalFallbackUses': FallbackApiService.maxUsageCount,
    };
  }
}
