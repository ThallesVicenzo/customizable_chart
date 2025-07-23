import 'package:customizable_chart/l10n/global_app_localizations.dart';
import 'package:customizable_chart/model/chart_data_model.dart';
import 'package:customizable_chart/viewmodel/chart_viewmodel.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerSingleton<GlobalAppLocalizations>(GlobalAppLocalizationsImpl());

  sl.registerFactory(() => ChartViewModel());

  sl.registerFactory(() => ChartDataModel.defaultData());
}
