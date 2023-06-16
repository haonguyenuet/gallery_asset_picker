import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    Key? key,
    this.label,
    this.onPressed,
    this.width,
    this.height,
    this.backgroundColor,
  }) : super(key: key);

  final String? label;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final ValueChanged<BuildContext>? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 40,
      child: ElevatedButton(
        onPressed: () => onPressed?.call(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label ?? ''),
      ),
    );
  }
}
