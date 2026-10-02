import 'package:flutter/material.dart';

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
          child: TextField(
            controller: controller,
            enabled: enabled,
            autofocus: true,
            onSubmitted: (_) => onSubmit(),
            decoration: const InputDecoration(
              hintText: 'Cole o link do YouTube ou YouTube Music',
              prefixIcon: Icon(Icons.link),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: enabled ? onSubmit : null,
          icon: const Icon(Icons.search),
          label: const Text('Buscar'),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 56)),
        ),
      ],
    );
  }
}
