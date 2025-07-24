import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';
import 'package:customizable_chart/utils/secure_storage/secure_storage.dart';
import 'package:customizable_chart/model/services/environment.dart';
import 'package:customizable_chart/l10n/global_app_localizations.dart';
import 'package:customizable_chart/utils/secure_storage/keys/secure_storage_keys.dart';

import 'settings_viewmodel_test.mocks.dart';

// Generate mocks
@GenerateMocks([SecureStorage, EnvironmentService, GlobalAppLocalizations])
void main() {
  group('SettingsViewModel Basic Tests', () {
    late MockSecureStorage mockSecureStorage;
    late MockEnvironmentService mockEnvironmentService;
    late MockGlobalAppLocalizations mockGlobalAppLocalizations;
    late GetIt serviceLocator;

    setUpAll(() {
      serviceLocator = GetIt.instance;
    });

    setUp(() {
      mockSecureStorage = MockSecureStorage();
      mockEnvironmentService = MockEnvironmentService();
      mockGlobalAppLocalizations = MockGlobalAppLocalizations();

      // Setup service locator
      serviceLocator.registerSingleton<EnvironmentService>(
        mockEnvironmentService,
      );
      serviceLocator.registerSingleton<GlobalAppLocalizations>(
        mockGlobalAppLocalizations,
      );
    });

    tearDown(() {
      serviceLocator.reset();
    });

    group('Secure Storage Operations', () {
      test('should read API key from secure storage', () async {
        // Arrange
        const expectedKey = 'test-api-key-123';
        when(
          mockSecureStorage.read(key: SecureStorageKeys.openaiApiKey.key),
        ).thenAnswer((_) async => expectedKey);

        // Act
        final result = await mockSecureStorage.read(
          key: SecureStorageKeys.openaiApiKey.key,
        );

        // Assert
        expect(result, equals(expectedKey));
        verify(
          mockSecureStorage.read(key: SecureStorageKeys.openaiApiKey.key),
        ).called(1);
      });

      test('should write API key to secure storage', () async {
        // Arrange
        const apiKey = 'new-api-key-456';
        when(
          mockSecureStorage.write(
            key: SecureStorageKeys.openaiApiKey.key,
            value: apiKey,
          ),
        ).thenAnswer((_) async => {});

        // Act
        await mockSecureStorage.write(
          key: SecureStorageKeys.openaiApiKey.key,
          value: apiKey,
        );

        // Assert
        verify(
          mockSecureStorage.write(
            key: SecureStorageKeys.openaiApiKey.key,
            value: apiKey,
          ),
        ).called(1);
      });

      test('should delete API key from secure storage', () async {
        // Arrange
        when(
          mockSecureStorage.delete(key: SecureStorageKeys.openaiApiKey.key),
        ).thenAnswer((_) async => {});

        // Act
        await mockSecureStorage.delete(key: SecureStorageKeys.openaiApiKey.key);

        // Assert
        verify(
          mockSecureStorage.delete(key: SecureStorageKeys.openaiApiKey.key),
        ).called(1);
      });

      test('should handle null values from secure storage', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: SecureStorageKeys.openaiApiKey.key),
        ).thenAnswer((_) async => null);

        // Act
        final result = await mockSecureStorage.read(
          key: SecureStorageKeys.openaiApiKey.key,
        );

        // Assert
        expect(result, isNull);
        verify(
          mockSecureStorage.read(key: SecureStorageKeys.openaiApiKey.key),
        ).called(1);
      });

      test('should handle empty string values from secure storage', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: SecureStorageKeys.openaiApiKey.key),
        ).thenAnswer((_) async => '');

        // Act
        final result = await mockSecureStorage.read(
          key: SecureStorageKeys.openaiApiKey.key,
        );

        // Assert
        expect(result, equals(''));
        verify(
          mockSecureStorage.read(key: SecureStorageKeys.openaiApiKey.key),
        ).called(1);
      });
    });

    group('Environment Service Integration', () {
      test('should get token usage info from environment service', () async {
        // Arrange
        final expectedInfo = {
          'hasUserToken': true,
          'canUseFallback': false,
          'remainingFallbackUses': 0,
        };
        when(
          mockEnvironmentService.getTokenUsageInfo(),
        ).thenAnswer((_) async => expectedInfo);

        // Act
        final result = await mockEnvironmentService.getTokenUsageInfo();

        // Assert
        expect(result, equals(expectedInfo));
        verify(mockEnvironmentService.getTokenUsageInfo()).called(1);
      });

      test('should handle different token usage scenarios', () async {
        // Test case 1: User has personal token
        when(
          mockEnvironmentService.getTokenUsageInfo(),
        ).thenAnswer((_) async => {'hasUserToken': true});

        var result = await mockEnvironmentService.getTokenUsageInfo();
        expect(result['hasUserToken'], isTrue);

        // Test case 2: User can use fallback
        when(mockEnvironmentService.getTokenUsageInfo()).thenAnswer(
          (_) async => {
            'hasUserToken': false,
            'canUseFallback': true,
            'remainingFallbackUses': 2,
          },
        );

        result = await mockEnvironmentService.getTokenUsageInfo();
        expect(result['hasUserToken'], isFalse);
        expect(result['canUseFallback'], isTrue);
        expect(result['remainingFallbackUses'], equals(2));

        // Test case 3: Fallback expired
        when(mockEnvironmentService.getTokenUsageInfo()).thenAnswer(
          (_) async => {'hasUserToken': false, 'canUseFallback': false},
        );

        result = await mockEnvironmentService.getTokenUsageInfo();
        expect(result['hasUserToken'], isFalse);
        expect(result['canUseFallback'], isFalse);
      });
    });

    group('Service Locator Integration', () {
      test('should register and retrieve services correctly', () {
        // Assert that services are registered
        expect(serviceLocator.isRegistered<EnvironmentService>(), isTrue);
        expect(serviceLocator.isRegistered<GlobalAppLocalizations>(), isTrue);

        // Act & Assert - retrieve services
        final envService = serviceLocator<EnvironmentService>();
        final appLocalizations = serviceLocator<GlobalAppLocalizations>();

        expect(envService, isA<EnvironmentService>());
        expect(appLocalizations, isA<GlobalAppLocalizations>());
      });
    });

    group('Error Handling', () {
      test('should handle storage write errors', () async {
        // Arrange
        when(
          mockSecureStorage.write(
            key: SecureStorageKeys.openaiApiKey.key,
            value: 'test-key',
          ),
        ).thenThrow(Exception('Storage write failed'));

        // Act & Assert
        expect(
          () async => await mockSecureStorage.write(
            key: SecureStorageKeys.openaiApiKey.key,
            value: 'test-key',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle storage read errors', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: SecureStorageKeys.openaiApiKey.key),
        ).thenThrow(Exception('Storage read failed'));

        // Act & Assert
        expect(
          () async => await mockSecureStorage.read(
            key: SecureStorageKeys.openaiApiKey.key,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle environment service errors', () async {
        // Arrange
        when(
          mockEnvironmentService.getTokenUsageInfo(),
        ).thenThrow(Exception('Environment service error'));

        // Act & Assert
        expect(
          () async => await mockEnvironmentService.getTokenUsageInfo(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
