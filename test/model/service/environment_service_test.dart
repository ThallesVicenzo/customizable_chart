import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:customizable_chart/model/services/environment.dart';
import 'package:customizable_chart/model/services/fallback_api_service.dart';
import 'package:customizable_chart/utils/secure_storage/secure_storage.dart';

import 'environment_service_test.mocks.dart';

// Generate mocks
@GenerateMocks([SecureStorage, FallbackApiService])
void main() {
  group('EnvironmentService Tests', () {
    late EnvironmentService environmentService;
    late MockSecureStorage mockSecureStorage;
    late MockFallbackApiService mockFallbackApiService;

    setUp(() {
      mockSecureStorage = MockSecureStorage();
      mockFallbackApiService = MockFallbackApiService();
      environmentService = EnvironmentServiceImplementation(
        mockSecureStorage,
        mockFallbackApiService,
      );
    });

    group('getAuthToken', () {
      test('should return user token when available', () async {
        // Arrange
        const userToken = 'user-api-key-123';
        when(
          mockSecureStorage.read(key: 'openai_api_key'),
        ).thenAnswer((_) async => userToken);

        // Act
        final token = await environmentService.getAuthToken();

        // Assert
        expect(token, equals(userToken));
        verify(mockSecureStorage.read(key: 'openai_api_key')).called(1);
      });

      test(
        'should use fallback when no user token and fallback available',
        () async {
          // Arrange
          const fallbackToken = 'fallback-api-key-456';
          when(
            mockSecureStorage.read(key: 'openai_api_key'),
          ).thenAnswer((_) async => null);
          when(
            mockFallbackApiService.canUseFallbackApi(),
          ).thenAnswer((_) async => true);
          when(
            mockFallbackApiService.getFallbackApiKey(),
          ).thenReturn(fallbackToken);

          // Act
          final token = await environmentService.getAuthToken();

          // Assert
          expect(token, equals(fallbackToken));
          verify(mockSecureStorage.read(key: 'openai_api_key')).called(1);
          verify(mockFallbackApiService.canUseFallbackApi()).called(1);
          verify(mockFallbackApiService.getFallbackApiKey()).called(1);
        },
      );

      test(
        'should return null when no user token and fallback not available',
        () async {
          // Arrange
          when(
            mockSecureStorage.read(key: 'openai_api_key'),
          ).thenAnswer((_) async => null);
          when(
            mockFallbackApiService.canUseFallbackApi(),
          ).thenAnswer((_) async => false);

          // Act
          final token = await environmentService.getAuthToken();

          // Assert
          expect(token, isNull);
          verify(mockSecureStorage.read(key: 'openai_api_key')).called(1);
          verify(mockFallbackApiService.canUseFallbackApi()).called(1);
          verifyNever(mockFallbackApiService.getFallbackApiKey());
        },
      );
    });

    group('getTokenUsageInfo', () {
      test(
        'should return complete usage information with user token',
        () async {
          // Arrange
          const userToken = 'user-api-key-123';
          const remainingUses = 2;

          when(
            mockSecureStorage.read(key: 'openai_api_key'),
          ).thenAnswer((_) async => userToken);
          when(
            mockFallbackApiService.getRemainingUsageCount(),
          ).thenAnswer((_) async => remainingUses);
          when(
            mockFallbackApiService.canUseFallbackApi(),
          ).thenAnswer((_) async => true);

          // Act
          final info = await environmentService.getTokenUsageInfo();

          // Assert
          expect(info, isA<Map<String, dynamic>>());
          expect(info['hasUserToken'], isTrue);
          expect(info['remainingFallbackUses'], equals(remainingUses));
          expect(info['canUseFallback'], isTrue);
          expect(
            info['totalFallbackUses'],
            equals(3),
          ); // FallbackApiService.maxUsageCount

          verify(mockSecureStorage.read(key: 'openai_api_key')).called(1);
          verify(mockFallbackApiService.getRemainingUsageCount()).called(1);
          verify(mockFallbackApiService.canUseFallbackApi()).called(1);
        },
      );

      test('should return info without user token', () async {
        // Arrange
        const remainingUses = 3;

        when(
          mockSecureStorage.read(key: 'openai_api_key'),
        ).thenAnswer((_) async => null);
        when(
          mockFallbackApiService.getRemainingUsageCount(),
        ).thenAnswer((_) async => remainingUses);
        when(
          mockFallbackApiService.canUseFallbackApi(),
        ).thenAnswer((_) async => true);

        // Act
        final info = await environmentService.getTokenUsageInfo();

        // Assert
        expect(info['hasUserToken'], isFalse);
        expect(info['remainingFallbackUses'], equals(remainingUses));
        expect(info['canUseFallback'], isTrue);
        expect(
          info['totalFallbackUses'],
          equals(3),
        ); // FallbackApiService.maxUsageCount
      });

      test('should show no fallback available when limit reached', () async {
        // Arrange
        const remainingUses = 0;

        when(
          mockSecureStorage.read(key: 'openai_api_key'),
        ).thenAnswer((_) async => null);
        when(
          mockFallbackApiService.getRemainingUsageCount(),
        ).thenAnswer((_) async => remainingUses);
        when(
          mockFallbackApiService.canUseFallbackApi(),
        ).thenAnswer((_) async => false);

        // Act
        final info = await environmentService.getTokenUsageInfo();

        // Assert
        expect(info['hasUserToken'], isFalse);
        expect(info['remainingFallbackUses'], equals(0));
        expect(info['canUseFallback'], isFalse);
        expect(
          info['totalFallbackUses'],
          equals(3),
        ); // FallbackApiService.maxUsageCount
      });
    });
  });
}
