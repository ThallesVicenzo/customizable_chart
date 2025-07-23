import 'package:flutter/material.dart';

class PresetButton extends StatelessWidget {
  final String prompt;
  final Color color;
  final VoidCallback onPressed;

  const PresetButton({
    super.key,
    required this.prompt,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      child: Text(
        '"$prompt"',
        style: const TextStyle(
          fontSize: 11,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
