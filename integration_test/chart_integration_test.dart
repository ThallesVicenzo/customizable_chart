import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:customizable_chart/main.dart' as app;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'helpers/mock_helper.dart';
import 'test_flows/chart_customization_flow.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Chart Customization Integration Tests', () {
    late IntegrationTestMockHelper mockHelper;
    late ChartCustomizationFlow testFlow;

    setUpAll(() async {
      // Initialize dotenv for testing
      await dotenv.load(fileName: ".env");
    });

    setUp(() async {
      mockHelper = IntegrationTestMockHelper();
      testFlow = ChartCustomizationFlow();

      mockHelper.initializeMocks();
      mockHelper.setupMockBehaviors();
      await mockHelper.registerMocks();
    });

    tearDown(() async {
      await mockHelper.cleanup();
    });

    testWidgets(
      'Critical Flow: Chart customization with AI and fallback commands',
      (WidgetTester tester) async {
        await tester.pumpWidget(const app.MyApp());
        await tester.pumpAndSettle();

        // Test basic app loading
        await testFlow.verifyAppLoadsSuccessfully(tester);

        // Test AI-powered customization
        mockHelper.setApiCallToFail(false);
        await testFlow.testAIPoweredCustomization(tester);

        // Test fallback to preset commands
        mockHelper.setApiCallToFail(true);
        await testFlow.testPresetCommandFallback(tester);

        // Test settings navigation and configuration
        await testFlow.testSettingsNavigation(tester);
        await testFlow.testApiKeyConfiguration(tester);

        // Test return to chart and reset functionality
        await testFlow.testReturnToChartAndReset(tester);

        // Test multiple preset buttons
        await testFlow.testMultiplePresetButtons(tester);

        // Final verification
        await testFlow.verifyAllCriticalComponentsPresent(tester);

        log('✅ Integration Test Completed Successfully!');
        log(
          '✅ Tested: AI commands, fallback behavior, navigation, settings, reset',
        );
        log('✅ Critical user flow validation passed');
      },
    );

    testWidgets('Error Handling: API failure scenarios', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      // Test error handling with API failures
      mockHelper.setApiCallToFail(true);
      await testFlow.testErrorHandlingScenarios(tester);

      log('✅ Error handling test completed successfully!');
    });
  });
}
