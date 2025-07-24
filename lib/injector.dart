import 'package:customizable_chart/l10n/global_app_localizations.dart';
import 'package:customizable_chart/model/models/chart_data_model.dart';
import 'package:customizable_chart/model/services/client/client_http.dart';
import 'package:customizable_chart/model/services/client/dio/dio_client.dart';
import 'package:customizable_chart/model/services/fallback_api_service.dart';
import 'package:customizable_chart/model/services/environment.dart';
import 'package:customizable_chart/model/repositories/llm_repository.dart';
import 'package:customizable_chart/viewmodel/chart_viewmodel.dart';
import 'package:customizable_chart/viewmodel/settings_viewmodel.dart';
import 'package:customizable_chart/utils/secure_storage/secure_storage.dart';
import 'package:customizable_chart/utils/secure_storage/secure_storage_impl.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerSingleton<SecureStorage>(SecureStorageImpl());

  sl.registerSingleton<ClientHttp>(DioClient());

  sl.registerSingleton<GlobalAppLocalizations>(GlobalAppLocalizationsImpl());

  sl.registerSingleton<FallbackApiService>(
    FallbackApiServiceImplementation(sl()),
  );

  sl.registerSingleton<EnvironmentService>(
    EnvironmentServiceImplementation(sl(), sl()),
  );

  sl.registerSingleton<LlmRepository>(LLMRepositoryImplementation(sl()));

  sl.registerFactory(() => ChartViewModel());

  sl.registerFactory(() => SettingsViewModel(sl()));

  sl.registerFactory(() => ChartDataModel.defaultData());
}
