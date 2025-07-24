import 'package:flutter/material.dart';
import 'package:customizable_chart/view/settings_page.dart';
import 'package:customizable_chart/l10n/global_app_localizations.dart';

class ErrorSnackbar {
  static void show({
    required BuildContext context,
    required String errorMessage,
    required AppLocalizations localizations,
  }) {
    final errorMessageLower = errorMessage.toLowerCase();
    final isTrialExpiredError = _isTrialExpiredError(errorMessageLower);

    final simplifiedMessage =
        isTrialExpiredError
            ? localizations.freeTrialExpiredStatus
            : localizations.promptErrorProcessingRequest;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            isTrialExpiredError
                ? _buildTrialExpiredContent(
                  context,
                  simplifiedMessage,
                  localizations,
                )
                : _buildGenericErrorContent(simplifiedMessage),
        backgroundColor:
            isTrialExpiredError ? Colors.orange[800] : Colors.red[700],
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static bool _isTrialExpiredError(String errorMessage) {
    return (errorMessage.contains('teste gratuito') &&
            errorMessage.contains('expirou')) ||
        (errorMessage.contains('free trial') &&
            errorMessage.contains('expired')) ||
        (errorMessage.contains('free ai trials') &&
            errorMessage.contains('used up')) ||
        errorMessage.contains('seu período de teste gratuito expirou');
  }

  static Widget _buildTrialExpiredContent(
    BuildContext context,
    String message,
    AppLocalizations localizations,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(localizations.settings),
        ),
      ],
    );
  }

  static Widget _buildGenericErrorContent(String message) {
    return Text(message, style: const TextStyle(color: Colors.white));
  }
}
