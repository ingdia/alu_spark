import 'package:flutter/material.dart';
import 'package:alu_spark/app/theme/app_colors.dart';

/// Displays a circular avatar with an acronym derived from [name].
/// If [imageUrl] is provided and loads successfully, the image is shown instead.
/// [name] can be a full name ("John Doe" → "JD") or a startup name ("ALU Spark" → "AS").
class AvatarWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final Color? textColor;

  const AvatarWidget({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 36,
    this.borderColor,
    this.borderWidth = 0,
    this.backgroundColor,
    this.textColor,
  });

  static String acronymOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final acronym = acronymOf(name);
    final fontSize = radius * 0.52;

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.darkBlueLight,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      onBackgroundImageError: imageUrl != null ? (_, __) {} : null,
      child: imageUrl == null
          ? Text(
              acronym,
              style: TextStyle(
                color: textColor ?? AppColors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            )
          : null,
    );

    if (borderColor != null && borderWidth > 0) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor!, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: borderColor!.withValues(alpha: 0.35),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: avatar,
      );
    }

    return avatar;
  }
}
