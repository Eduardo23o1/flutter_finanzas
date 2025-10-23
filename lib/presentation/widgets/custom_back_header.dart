import 'package:flutter/material.dart';

class CustomBackHeader extends StatelessWidget {
  final String text;
  final bool centerText;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final VoidCallback? onBack;
  final IconData icon;

  const CustomBackHeader({
    super.key,
    required this.text,
    this.centerText = false,
    this.backgroundColor = Colors.blueAccent,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.icon = Icons.arrow_back,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          centerText ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onBack ?? () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24,
              child: Icon(icon, color: iconColor, size: 26),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
