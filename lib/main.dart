import 'package:customizable_chart/l10n/global_app_localizations.dart';
import 'package:customizable_chart/view/chart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:customizable_chart/injector.dart' as injector;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  await injector.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customizable Chart',
      debugShowCheckedModeBanner: false,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      builder: (context, child) {
        injector.sl<GlobalAppLocalizations>().setAppLocalizations(
          AppLocalizations.of(context)!,
        );
        return ChartPage();
      },
    );
  }
}
