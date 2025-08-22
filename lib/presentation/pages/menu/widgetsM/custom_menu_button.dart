import 'package:flutter/material.dart';

class CustomMenuButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onPressed;

  const CustomMenuButton({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: onPressed,
            child: Image.asset(
              imagePath,
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
