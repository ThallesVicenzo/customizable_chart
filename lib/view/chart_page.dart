import 'package:customizable_chart/view/components/customizable_chart.dart';
import 'package:customizable_chart/view/components/prompt_section.dart';
import 'package:customizable_chart/viewmodel/chart_viewmodel.dart';
import 'package:customizable_chart/l10n/global_app_localizations.dart';
import 'package:customizable_chart/injector.dart';
import 'package:flutter/material.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  late ChartViewModel _viewModel;
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ChartViewModel>();
    _localizations = sl<GlobalAppLocalizations>().current;
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, child) {
            return Text(_localizations.chartTitle);
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _viewModel.resetData(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: AnimatedBuilder(
                    animation: _viewModel,
                    builder: (context, child) {
                      return CustomizableChart(chartData: _viewModel.chartData);
                    },
                  ),
                ),
              ),
              Text(
                _localizations.textPrompts,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PromptSection(viewModel: _viewModel),
            ],
          ),
        ),
      ),
    );
  }
}
