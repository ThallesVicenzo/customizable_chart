import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';

import 'package:customizable_chart/model/repositories/llm_repository.dart';
import 'package:customizable_chart/model/services/client/client_http.dart';
import 'package:customizable_chart/model/services/client/client_http_request.dart';
import 'package:customizable_chart/model/services/environment.dart';

import 'llm_repository_test.mocks.dart';

// Generate mocks
@GenerateMocks([EnvironmentService])
void main() {
  group('LlmRepository Tests', () {
    late LlmRepository repository;
    late MockEnvironmentService mockEnvironmentService;
    late GetIt serviceLocator;

    // Manual mock for ClientHttp since it may not work with GenerateMocks
    final mockClientHttp = _MockClientHttp();

    setUp(() {
      serviceLocator = GetIt.instance;
      mockEnvironmentService = MockEnvironmentService();

      serviceLocator.registerSingleton<EnvironmentService>(
        mockEnvironmentService,
      );

      repository = LLMRepositoryImplementation(mockClientHttp);
    });

    tearDown(() {
      GetIt.instance.reset();
    });

    group('configToChartData', () {
      test(
        'should convert configuration to ChartDataModel with default values',
        () {
          final config = <String, dynamic>{
            'values': [1.0, 2.0, 3.0, 4.0, 5.0],
            'lineColor': Colors.blue,
            'gradientStartColor': Colors.blue.withValues(alpha: 0.3),
            'gradientEndColor': Colors.blue.withValues(alpha: 0.1),
            'lineWidth': 2.5,
            'showGrid': true,
            'showTooltip': true,
          };

          // Act
          final chartData = repository.configToChartData(config);

          // Assert
          expect(chartData.values, equals([1.0, 2.0, 3.0, 4.0, 5.0]));
          expect(chartData.lineWidth, equals(2.5));
          expect(chartData.showGrid, isTrue);
          expect(chartData.showTooltip, isTrue);
          expect(chartData.lineColor, equals(Colors.blue));
        },
      );

      test('should convert configuration with custom values', () {
        // Arrange - need to use proper Color objects
        final config = <String, dynamic>{
          'values': [10.0, 20.0, 30.0],
          'lineColor': Colors.red,
          'gradientStartColor': Colors.red.withValues(alpha: 0.2),
          'gradientEndColor': Colors.red.withValues(alpha: 0.05),
          'lineWidth': 3.0,
          'showGrid': false,
          'showTooltip': false,
        };

        // Act
        final chartData = repository.configToChartData(config);

        // Assert
        expect(chartData.values, equals([10.0, 20.0, 30.0]));
        expect(chartData.lineWidth, equals(3.0));
        expect(chartData.showGrid, isFalse);
        expect(chartData.showTooltip, isFalse);
        expect(chartData.lineColor, equals(Colors.red));
      });
    });
  });
}

// Manual mock for ClientHttp
class _MockClientHttp implements ClientHttp {
  ClientHttpRequest? _nextResponse;
  Exception? _nextException;

  void setNextResponse(ClientHttpRequest response) {
    _nextResponse = response;
    _nextException = null;
  }

  void setNextException(Exception exception) {
    _nextException = exception;
    _nextResponse = null;
  }

  @override
  Future<ClientHttpRequest<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    if (_nextException != null) {
      throw _nextException!;
    }
    return _nextResponse as ClientHttpRequest<T>;
  }

  @override
  Future<ClientHttpRequest<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ClientHttpRequest<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ClientHttpRequest<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ClientHttpRequest<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ClientHttpRequest<T>> request<T>(
    String path, {
    dynamic data,
    required String method,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    throw UnimplementedError();
  }
}
