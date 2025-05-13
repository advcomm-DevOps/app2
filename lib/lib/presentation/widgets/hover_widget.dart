import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HoverWidget extends HookWidget {
  final Widget Function(bool isHovered) builder;

  const HoverWidget({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final isHovered = useState(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: builder(isHovered.value),
    );
  }
}
