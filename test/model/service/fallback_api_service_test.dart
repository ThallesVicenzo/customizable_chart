import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:customizable_chart/model/services/fallback_api_service.dart';
import 'package:customizable_chart/utils/secure_storage/secure_storage.dart';

import 'fallback_api_service_test.mocks.dart';

// Generate mocks
@GenerateMocks([SecureStorage])
void main() {
  group('FallbackApiService Tests', () {
    late FallbackApiService service;
    late MockSecureStorage mockSecureStorage;

    setUpAll(() async {
      // Initialize dotenv for testing
      TestWidgetsFlutterBinding.ensureInitialized();
      dotenv.testLoad(
        fileInput: '''
FALLBACK_OPENAI_API_KEY=test-fallback-key-123
''',
      );
    });

    setUp(() {
      mockSecureStorage = MockSecureStorage();
      service = FallbackApiServiceImplementation(mockSecureStorage);
    });

    group('getCurrentUsageCount', () {
      test('should return 0 when no usage count is stored', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => null);

        // Act
        final count = await service.getCurrentUsageCount();

        // Assert
        expect(count, equals(0));
        verify(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).called(1);
      });

      test('should return stored usage count', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => '2');

        // Act
        final count = await service.getCurrentUsageCount();

        // Assert
        expect(count, equals(2));
        verify(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).called(1);
      });

      test('should return 0 when stored value is invalid', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => 'invalid');

        // Act
        final count = await service.getCurrentUsageCount();

        // Assert
        expect(count, equals(0));
        verify(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).called(1);
      });
    });

    group('incrementUsageCount', () {
      test('should increment usage count from 0 to 1', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => null);
        when(
          mockSecureStorage.write(key: 'fallback_api_usage_count', value: '1'),
        ).thenAnswer((_) async {});

        // Act
        await service.incrementUsageCount();

        // Assert
        verify(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).called(1);
        verify(
          mockSecureStorage.write(key: 'fallback_api_usage_count', value: '1'),
        ).called(1);
      });

      test('should increment usage count from existing value', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => '2');
        when(
          mockSecureStorage.write(key: 'fallback_api_usage_count', value: '3'),
        ).thenAnswer((_) async {});

        // Act
        await service.incrementUsageCount();

        // Assert
        verify(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).called(1);
        verify(
          mockSecureStorage.write(key: 'fallback_api_usage_count', value: '3'),
        ).called(1);
      });
    });

    group('canUseFallbackApi', () {
      test('should return true when usage count is below maximum', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => '2');

        // Act
        final canUse = await service.canUseFallbackApi();

        // Assert
        expect(canUse, isTrue);
        verify(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).called(1);
      });

      test('should return false when usage count equals maximum', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => '3');

        // Act
        final canUse = await service.canUseFallbackApi();

        // Assert
        expect(canUse, isFalse);
        verify(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).called(1);
      });

      test('should return false when usage count exceeds maximum', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => '5');

        // Act
        final canUse = await service.canUseFallbackApi();

        // Assert
        expect(canUse, isFalse);
        verify(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).called(1);
      });

      test('should return true when no usage count is stored', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => null);

        // Act
        final canUse = await service.canUseFallbackApi();

        // Assert
        expect(canUse, isTrue);
        verify(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).called(1);
      });
    });

    group('getRemainingUsageCount', () {
      test('should return correct remaining count', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => '1');

        // Act
        final remaining = await service.getRemainingUsageCount();

        // Assert
        expect(remaining, equals(2)); // 3 - 1 = 2
        verify(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).called(1);
      });

      test('should return 0 when usage count equals maximum', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => '3');

        // Act
        final remaining = await service.getRemainingUsageCount();

        // Assert
        expect(remaining, equals(0)); // 3 - 3 = 0
        verify(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).called(1);
      });

      test('should return maximum count when no usage is stored', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => null);

        // Act
        final remaining = await service.getRemainingUsageCount();

        // Assert
        expect(remaining, equals(3)); // 3 - 0 = 3
        verify(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).called(1);
      });
    });

    group('getFallbackApiKey', () {
      test('should return fallback API key from environment', () {
        // Act
        final apiKey = service.getFallbackApiKey();

        // Assert
        expect(apiKey, equals('test-fallback-key-123'));
      });
    });

    group('getUserApiKey', () {
      test('should return user API key from secure storage', () async {
        // Arrange
        const userApiKey = 'user-api-key-456';
        when(
          mockSecureStorage.read(key: 'openai_api_key'),
        ).thenAnswer((_) async => userApiKey);

        // Act
        final apiKey = await service.getUserApiKey();

        // Assert
        expect(apiKey, equals(userApiKey));
        verify(mockSecureStorage.read(key: 'openai_api_key')).called(1);
      });

      test('should return null when no user API key is stored', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'openai_api_key'),
        ).thenAnswer((_) async => null);

        // Act
        final apiKey = await service.getUserApiKey();

        // Assert
        expect(apiKey, isNull);
        verify(mockSecureStorage.read(key: 'openai_api_key')).called(1);
      });
    });

    group('resetUsageCount', () {
      test('should delete usage count from secure storage', () async {
        // Arrange
        when(
          mockSecureStorage.delete(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async {});
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => null);

        // Act
        await service.resetUsageCount();

        // Assert
        verify(
          mockSecureStorage.delete(key: 'fallback_api_usage_count'),
        ).called(1);
        verify(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).called(1);
      });
    });

    group('integration tests', () {
      test('should handle complete usage flow correctly', () async {
        // Arrange - start with no usage
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => null);
        when(
          mockSecureStorage.write(
            key: 'fallback_api_usage_count',
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {});

        // Act & Assert - initial state
        expect(await service.getCurrentUsageCount(), equals(0));
        expect(await service.canUseFallbackApi(), isTrue);
        expect(await service.getRemainingUsageCount(), equals(3));

        // Act & Assert - after first increment
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => '1');
        await service.incrementUsageCount();
        expect(await service.getCurrentUsageCount(), equals(1));
        expect(await service.canUseFallbackApi(), isTrue);
        expect(await service.getRemainingUsageCount(), equals(2));

        // Act & Assert - after second increment
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => '2');
        await service.incrementUsageCount();
        expect(await service.getCurrentUsageCount(), equals(2));
        expect(await service.canUseFallbackApi(), isTrue);
        expect(await service.getRemainingUsageCount(), equals(1));

        // Act & Assert - after third increment (reaches limit)
        when(
          mockSecureStorage.read(key: 'fallback_api_usage_count'),
        ).thenAnswer((_) async => '3');
        await service.incrementUsageCount();
        expect(await service.getCurrentUsageCount(), equals(3));
        expect(await service.canUseFallbackApi(), isFalse);
        expect(await service.getRemainingUsageCount(), equals(0));
      });

      test('should respect maximum usage limit constant', () {
        // Assert
        expect(FallbackApiService.maxUsageCount, equals(3));
      });
    });
  });
}
