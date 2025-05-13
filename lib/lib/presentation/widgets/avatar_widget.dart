import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;

  const AvatarWidget({
    super.key,
    required this.name,
    this.size = 36,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final avatarText = _getAvatarText(name);
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          avatarText,
          style: TextStyle(
            fontSize: size * 0.4,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getAvatarText(String name) {
    // Split by any whitespace and filter out empty strings
    final words =
        name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    if (words.length >= 2) {
      // Get first two non-empty words and their first letters
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }

    // For single word names
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }
}
