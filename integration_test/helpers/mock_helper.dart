import 'package:mockito/mockito.dart';
import 'package:customizable_chart/injector.dart' as injector;
import 'package:customizable_chart/model/services/client/client_http.dart';
import 'package:customizable_chart/model/services/client/client_http_request.dart';
import 'package:customizable_chart/utils/secure_storage/secure_storage.dart';
import 'package:customizable_chart/model/services/environment.dart';
import 'package:customizable_chart/model/services/fallback_api_service.dart';
import 'package:customizable_chart/model/repositories/llm_repository.dart';
import 'package:customizable_chart/l10n/global_app_localizations.dart';
import 'package:customizable_chart/viewmodel/chart_viewmodel.dart';
import 'package:customizable_chart/viewmodel/settings_viewmodel.dart';
import 'package:customizable_chart/model/models/chart_data_model.dart';

import '../../test/integration_test_mocks.mocks.dart';

/// Helper class to set up and manage mocks for integration tests
class IntegrationTestMockHelper {
  late MockClientHttp mockClientHttp;
  late MockSecureStorage mockSecureStorage;
  late MockEnvironmentService mockEnvironmentService;
  late MockFallbackApiService mockFallbackApiService;
  late MockLlmRepository mockLlmRepository;
  late MockGlobalAppLocalizations mockGlobalAppLocalizations;

  bool shouldFailApiCall = false;

  /// Initialize all mocks
  void initializeMocks() {
    mockClientHttp = MockClientHttp();
    mockSecureStorage = MockSecureStorage();
    mockEnvironmentService = MockEnvironmentService();
    mockFallbackApiService = MockFallbackApiService();
    mockLlmRepository = MockLlmRepository();
    mockGlobalAppLocalizations = MockGlobalAppLocalizations();
  }

  /// Configure mock behaviors
  void setupMockBehaviors() {
    // Configure ClientHttp mock
    when(mockClientHttp.post<Map<String, dynamic>>(
      any,
      data: anyNamed('data'),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async {
      if (shouldFailApiCall) {
        return ClientHttpRequest<Map<String, dynamic>>(
          statusCode: 500,
          statusMessage: 'Internal Server Error',
          data: null,
        );
      }

      // Mock successful OpenAI response
      final mockResponse = {
        'choices': [
          {
            'message': {
              'content': '''
{
  "success": true,
  "config": {
    "values": [15.0, 35.0, 25.0, 60.0, 45.0, 80.0, 65.0, 90.0, 75.0, 95.0],
    "lineColor": "#FF0000",
    "gradientStartColor": "#FF0000",
    "gradientEndColor": "#FF0000",
    "lineWidth": 4.5,
    "showGrid": true,
    "showTooltip": true,
    "description": "Changed to red with thick lines"
  }
}'''
            }
          }
        ]
      };

      return ClientHttpRequest<Map<String, dynamic>>(
        statusCode: 200,
        statusMessage: 'OK',
        data: mockResponse,
      );
    });

    // Configure SecureStorage mock
    final storageData = <String, String>{};
    when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
        .thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      final value = invocation.namedArguments[#value] as String;
      storageData[key] = value;
    });

    when(mockSecureStorage.read(key: anyNamed('key')))
        .thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      return storageData[key];
    });

    when(mockSecureStorage.delete(key: anyNamed('key')))
        .thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      storageData.remove(key);
    });

    when(mockSecureStorage.containsKey(any))
        .thenAnswer((invocation) async {
      final key = invocation.positionalArguments[0] as String;
      return storageData.containsKey(key);
    });

    when(mockSecureStorage.eraseAll()).thenAnswer((_) async {
      storageData.clear();
    });

    // Configure EnvironmentService mock
    when(mockEnvironmentService.getAuthToken()).thenAnswer((_) async => 'mock-token');
    when(mockEnvironmentService.getTokenUsageInfo()).thenAnswer((_) async => {
      'hasUserToken': false,
      'canUseFallback': true,
      'remainingFallbackUses': 3,
      'totalFallbackUses': 0,
    });

    // Configure FallbackApiService mock
    when(mockFallbackApiService.canUseFallbackApi()).thenAnswer((_) async => true);
    when(mockFallbackApiService.getRemainingUsageCount()).thenAnswer((_) async => 3);
    when(mockFallbackApiService.getCurrentUsageCount()).thenAnswer((_) async => 0);
    when(mockFallbackApiService.getFallbackApiKey()).thenReturn('fallback-key');
    when(mockFallbackApiService.getUserApiKey()).thenAnswer((_) async => null);
    when(mockFallbackApiService.incrementUsageCount()).thenAnswer((_) async {});
    when(mockFallbackApiService.resetUsageCount()).thenAnswer((_) async {});
  }

  /// Register all mocks with the service locator
  Future<void> registerMocks() async {
    await injector.sl.reset();

    injector.sl.registerSingleton<SecureStorage>(mockSecureStorage);
    injector.sl.registerSingleton<ClientHttp>(mockClientHttp);
    injector.sl.registerSingleton<GlobalAppLocalizations>(
        GlobalAppLocalizationsImpl());
    injector.sl.registerSingleton<FallbackApiService>(
        FallbackApiServiceImplementation(mockSecureStorage));
    injector.sl.registerSingleton<EnvironmentService>(
        EnvironmentServiceImplementation(
            mockSecureStorage, injector.sl<FallbackApiService>()));
    injector.sl.registerSingleton<LlmRepository>(
        LLMRepositoryImplementation(mockClientHttp));

    // Register ViewModels
    injector.sl.registerFactory(() => ChartViewModel());
    injector.sl.registerFactory(() => SettingsViewModel(mockSecureStorage));
    injector.sl.registerFactory(() => ChartDataModel.defaultData());
  }

  /// Clean up after tests
  Future<void> cleanup() async {
    await injector.sl.reset();
  }

  /// Set API call to fail for testing error scenarios
  void setApiCallToFail(bool shouldFail) {
    shouldFailApiCall = shouldFail;
  }
}
