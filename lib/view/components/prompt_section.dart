import 'package:customizable_chart/injector.dart';
import 'package:customizable_chart/l10n/global_app_localizations.dart';
import 'package:flutter/material.dart';
import '../../viewmodel/chart_viewmodel.dart';

class PromptSection extends StatefulWidget {
  final ChartViewModel viewModel;
  const PromptSection({super.key, required this.viewModel});

  @override
  State<PromptSection> createState() => _PromptSectionState();
}

class _PromptSectionState extends State<PromptSection> {
  final FocusNode _promptFocusNode = FocusNode();
  final AppLocalizations localizations = sl<GlobalAppLocalizations>().current;

  @override
  void dispose() {
    _promptFocusNode.dispose();
    super.dispose();
  }

  void _processPrompt() {
    final prompt = widget.viewModel.promptController.text.trim();
    final success = widget.viewModel.processTextPromptWithResult(
      prompt,
      localizations.promptErrorNotRecognized,
    );
    if (success) {
      _promptFocusNode.unfocus();
    }
  }

  void _useExamplePrompt(String prompt) {
    widget.viewModel.useExamplePrompt(
      prompt,
      localizations.promptErrorNotRecognized,
    );
    _promptFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, child) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
            minHeight: 200,
          ),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.viewModel.promptController,
                        focusNode: _promptFocusNode,
                        decoration: InputDecoration(
                          hintText: localizations.promptHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send, size: 20),
                            onPressed: () => _processPrompt(),
                          ),
                        ),
                        onSubmitted: (_) => _processPrompt(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.tryExamples,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children:
                      widget.viewModel.getExamplePrompts().map((prompt) {
                        return GestureDetector(
                          onTap: () => _useExamplePrompt(prompt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              prompt,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                if (widget.viewModel.lastPromptResult != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      widget.viewModel.lastPromptResult!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
