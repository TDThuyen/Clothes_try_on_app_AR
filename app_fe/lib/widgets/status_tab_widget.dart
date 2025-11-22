import 'package:flutter/material.dart';

class StatusTabWidget extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const StatusTabWidget({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : const Color(0xffE6E6E6),
          borderRadius: BorderRadius.circular(30),
        ),

        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
