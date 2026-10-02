import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class UrlInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmit;

  const UrlInput({super.key, required this.controller, required this.enabled, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FTextField(
            control: .managed(controller: controller),
            hint: 'Cole o link do YouTube ou YouTube Music',
            enabled: enabled,
            autofocus: true,
            onSubmit: (_) => onSubmit(),
            prefixBuilder: (context, style, variants) =>
                FTextField.prefixIconBuilder(context, style, variants, const Icon(FLucideIcons.link)),
          ),
        ),
        const SizedBox(width: 8),
        FButton(
          onPress: enabled ? onSubmit : null,
          mainAxisSize: .min,
          prefix: const Icon(FLucideIcons.search),
          child: const Text('Buscar'),
        ),
      ],
    );
  }
}
