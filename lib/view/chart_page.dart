import 'package:customizable_chart/view/components/customizable_chart.dart';
import 'package:customizable_chart/view/components/prompt_section.dart';
import 'package:customizable_chart/view/settings_page.dart';
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

    _viewModel.addListener(_handleViewModelChanges);
  }

  void _handleViewModelChanges() {
    if (_viewModel.lastPromptResult != null &&
        _viewModel.lastPromptResult!.isNotEmpty &&
        mounted) {
      String simplifiedMessage;
      bool isApiKeyError = _viewModel.lastPromptResult!.contains(
        'To use the AI functionality',
      );

      if (isApiKeyError) {
        simplifiedMessage = _localizations.promptErrorApiKeyRequired;
      } else {
        simplifiedMessage = _localizations.promptErrorProcessingRequest;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              isApiKeyError
                  ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          simplifiedMessage,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(_localizations.settings),
                      ),
                    ],
                  )
                  : Text(
                    simplifiedMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
          backgroundColor: isApiKeyError ? Colors.orange[800] : Colors.red[700],
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
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
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
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
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 180,
                    maxHeight: 300,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: AnimatedBuilder(
                    animation: _viewModel,
                    builder: (context, child) {
                      return CustomizableChart(chartData: _viewModel.chartData);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _localizations.textPrompts,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(child: PromptSection(viewModel: _viewModel)),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChanges);
    _viewModel.dispose();
    super.dispose();
  }
}
