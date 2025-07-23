import 'package:customizable_chart/injector.dart';
import 'package:customizable_chart/l10n/global_app_localizations.dart';
import 'package:flutter/material.dart';
import '../../viewmodel/chart_viewmodel.dart';
import 'preset_button.dart';

class PromptSection extends StatefulWidget {
  final ChartViewModel viewModel;
  const PromptSection({super.key, required this.viewModel});

  @override
  State<PromptSection> createState() => _PromptSectionState();
}

class _PromptSectionState extends State<PromptSection> {
  final AppLocalizations localizations = sl<GlobalAppLocalizations>().current;

  @override
  void dispose() {
    widget.viewModel.promptFocusNode.dispose();
    super.dispose();
  }

  Future<void> _processPrompt() async {
    await widget.viewModel.processPrompt(
      localizations.promptErrorNotRecognized,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, child) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
            minHeight: 120,
          ),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.viewModel.promptController,
                      focusNode: widget.viewModel.promptFocusNode,
                      decoration: InputDecoration(
                        hintText: localizations.promptHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        suffixIcon:
                            widget.viewModel.isProcessing
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                                : IconButton(
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
              const SizedBox(height: 16),
              Text(
                localizations.tryExamples,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      PresetButton(
                        prompt: localizations.promptBlueSales,
                        color: Colors.blue,
                        onPressed:
                            () => widget.viewModel.processSimulatedPrompt(
                              localizations.promptBlueSales,
                            ),
                      ),
                      PresetButton(
                        prompt: localizations.promptRedBold,
                        color: Colors.red,
                        onPressed:
                            () => widget.viewModel.processSimulatedPrompt(
                              localizations.promptRedBold,
                            ),
                      ),
                      PresetButton(
                        prompt: localizations.promptMinimalGrid,
                        color: Colors.grey,
                        onPressed:
                            () => widget.viewModel.processSimulatedPrompt(
                              localizations.promptMinimalGrid,
                            ),
                      ),
                      PresetButton(
                        prompt: localizations.promptOrangeTrending,
                        color: Colors.orange,
                        onPressed:
                            () => widget.viewModel.processSimulatedPrompt(
                              localizations.promptOrangeTrending,
                            ),
                      ),
                      PresetButton(
                        prompt: localizations.promptPurpleThick,
                        color: Colors.purple,
                        onPressed:
                            () => widget.viewModel.processSimulatedPrompt(
                              localizations.promptPurpleThick,
                            ),
                      ),
                    ],
                  ),
                ),
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
                    style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
