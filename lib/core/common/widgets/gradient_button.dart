import 'package:flutter/material.dart';

class GradientActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;
  final Gradient gradient;
  final TextStyle textStyle;

  const GradientActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 50,
    this.borderRadius = 30,
    this.gradient = const LinearGradient(
      colors: [Color(0xFFA11A7E), Color(0xFF852093), Color(0xFF7920A2)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(label, style: textStyle),
      ),
    );
  }
}
