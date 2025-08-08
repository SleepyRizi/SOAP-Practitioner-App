import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  /// Optional asset in `assets/images/…` shown at the start of the button.
  final String? iconAsset;
  /// Width of the icon. Defaults to 22 px if not provided.
  final double iconSize;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.iconAsset,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor   = outlined ? Colors.transparent : AppColors.primary;
    final textColor = outlined ? AppColors.primary : Colors.white;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: AppColors.primary, width: outlined ? 1.4 : 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: outlined ? 0 : 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── optional icon ──
          if (iconAsset != null) ...[
            Image.asset(
              iconAsset!,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
