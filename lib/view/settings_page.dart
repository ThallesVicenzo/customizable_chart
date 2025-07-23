import 'package:flutter/material.dart';
import 'package:customizable_chart/injector.dart';
import 'package:customizable_chart/viewmodel/settings_viewmodel.dart';
import 'package:customizable_chart/l10n/global_app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  late final SettingsViewModel _viewModel;
  late final AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<SettingsViewModel>();
    _localizations = sl<GlobalAppLocalizations>().current;
  }

  Future<void> _saveApiKey() async {
    await _viewModel.saveApiKey(_apiKeyController.text);
  }

  Future<void> _removeApiKey() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(_localizations.removeApiKeyTitle),
            content: Text(_localizations.removeApiKeyConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(_localizations.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(_localizations.removeApiKey),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _viewModel.removeApiKey();
      _apiKeyController.clear();
    }
  }

  void _editApiKey() {
    _viewModel.editApiKey();
    _apiKeyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_localizations.settings),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          if (_viewModel.hasApiKey &&
              _viewModel.isObscured &&
              _apiKeyController.text.isEmpty) {
            _apiKeyController.text = _viewModel.maskedKey;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.smart_toy,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _localizations.aiConfiguration,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _localizations.aiConfigurationDescription,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _apiKeyController,
                          obscureText: _viewModel.isObscured,
                          decoration: InputDecoration(
                            labelText: _localizations.openaiApiKey,
                            hintText: _localizations.apiKeyHint,
                            border: const OutlineInputBorder(),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_viewModel.hasApiKey &&
                                    _viewModel.isObscured) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: _editApiKey,
                                    tooltip: _localizations.editKey,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: _removeApiKey,
                                    tooltip: _localizations.removeKey,
                                  ),
                                ] else ...[
                                  IconButton(
                                    icon: Icon(
                                      _viewModel.isObscured
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: _viewModel.toggleObscureText,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          onSubmitted: (_) => _saveApiKey(),
                        ),
                        const SizedBox(height: 16),
                        if (!_viewModel.hasApiKey ||
                            !_viewModel.isObscured) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _viewModel.isLoading ? null : _saveApiKey,
                              child:
                                  _viewModel.isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(_localizations.saveKey),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (_viewModel.successMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _viewModel.successMessage!,
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (_viewModel.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error,
                                  color: Colors.red.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _viewModel.errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        ExpansionTile(
                          title: Text(_localizations.howToGetApiKey),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _localizations.apiKeyStep1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(_localizations.apiKeyStep2),
                                  const SizedBox(height: 8),
                                  Text(_localizations.apiKeyStep3),
                                  const SizedBox(height: 8),
                                  Text(_localizations.apiKeyStep4),
                                  const SizedBox(height: 8),
                                  Text(_localizations.apiKeyStep5),
                                  const SizedBox(height: 16),
                                  Text(
                                    _localizations.openaiCreditInfo,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
