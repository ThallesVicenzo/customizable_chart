import 'package:customizable_chart/l10n/global_app_localizations.dart';
import 'package:customizable_chart/model/models/chart_data_model.dart';
import 'package:customizable_chart/model/services/client/client_http.dart';
import 'package:customizable_chart/model/services/client/dio/dio_client.dart';
import 'package:customizable_chart/model/repositories/llm_repository.dart';
import 'package:customizable_chart/viewmodel/chart_viewmodel.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerSingleton<ClientHttp>(DioClient());

  sl.registerSingleton<LlmRepository>(LLMRepositoryImplementation(sl()));

  sl.registerSingleton<GlobalAppLocalizations>(GlobalAppLocalizationsImpl());

  sl.registerFactory(() => ChartViewModel());

  sl.registerFactory(() => ChartDataModel.defaultData());
}
