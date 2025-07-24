import 'package:flutter/material.dart';
import 'package:customizable_chart/viewmodel/services/secure_storage/secure_storage.dart';
import 'package:customizable_chart/viewmodel/services/secure_storage/keys/secure_storage_keys.dart';
import 'package:customizable_chart/model/services/environment.dart';
import 'package:customizable_chart/l10n/global_app_localizations.dart';
import 'package:customizable_chart/injector.dart';

class SettingsViewModel extends ChangeNotifier {
  final SecureStorage _secureStorage;
  final EnvironmentService _environmentService;
  late final AppLocalizations _localizations;

  SettingsViewModel(this._secureStorage)
    : _environmentService = sl<EnvironmentService>() {
    _localizations = sl<GlobalAppLocalizations>().current;
    loadApiKey();
  }

  bool _isObscured = true;
  bool _isLoading = false;
  bool _hasApiKey = false;
  String? _successMessage;
  String? _errorMessage;
  final String _maskedKey =
      '••••••••••••••••••••••••••••••••••••••••••••••••••••';

  bool get isObscured => _isObscured;
  bool get isLoading => _isLoading;
  bool get hasApiKey => _hasApiKey;
  String? get successMessage => _successMessage;
  String? get errorMessage => _errorMessage;
  String get maskedKey => _maskedKey;

  Future<void> loadApiKey() async {
    final apiKey = await _secureStorage.read(
      key: SecureStorageKeys.openaiApiKey.key,
    );
    _hasApiKey = apiKey != null && apiKey.isNotEmpty;
    notifyListeners();
  }

  Future<void> saveApiKey(String apiKey) async {
    if (apiKey.trim().isEmpty) {
      _errorMessage = _localizations.pleaseEnterApiKey;
      _successMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _secureStorage.write(
        key: SecureStorageKeys.openaiApiKey.key,
        value: apiKey.trim(),
      );

      _hasApiKey = true;
      _successMessage = _localizations.apiKeySavedSuccess;
      _isObscured = true;

      Future.delayed(const Duration(seconds: 3), () {
        _successMessage = null;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = _localizations.errorSavingKey(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeApiKey() async {
    await _secureStorage.delete(key: SecureStorageKeys.openaiApiKey.key);
    _hasApiKey = false;
    _successMessage = _localizations.apiKeyRemovedSuccess;
    _errorMessage = null;

    Future.delayed(const Duration(seconds: 3), () {
      _successMessage = null;
      notifyListeners();
    });

    notifyListeners();
  }

  void editApiKey() {
    _isObscured = false;
    notifyListeners();
  }

  void toggleObscureText() {
    _isObscured = !_isObscured;
    notifyListeners();
  }

  void clearMessages() {
    _successMessage = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getApiUsageInfo() async {
    return await _environmentService.getTokenUsageInfo();
  }

  Future<String> getUsageStatusMessage() async {
    final info = await getApiUsageInfo();

    if (info['hasUserToken'] == true) {
      return _localizations.personalApiKeyActive;
    } else if (info['canUseFallback'] == true) {
      final remaining = info['remainingFallbackUses'];
      return _localizations.freeTrialRemaining(remaining);
    } else {
      return _localizations.freeTrialExpiredStatus;
    }
  }
}
