import 'package:mockito/annotations.dart';
import 'package:customizable_chart/model/services/client/client_http.dart';
import 'package:customizable_chart/utils/secure_storage/secure_storage.dart';
import 'package:customizable_chart/model/services/environment.dart';
import 'package:customizable_chart/model/services/fallback_api_service.dart';
import 'package:customizable_chart/model/repositories/llm_repository.dart';
import 'package:customizable_chart/l10n/global_app_localizations.dart';
import 'package:customizable_chart/viewmodel/chart_viewmodel.dart';
import 'package:customizable_chart/viewmodel/settings_viewmodel.dart';

/// Generate mocks for integration testing
/// Run: flutter packages pub run build_runner build
@GenerateMocks([
  ClientHttp,
  SecureStorage,
  EnvironmentService,
  FallbackApiService,
  LlmRepository,
  GlobalAppLocalizations,
  ChartViewModel,
  SettingsViewModel,
])
void main() {}
