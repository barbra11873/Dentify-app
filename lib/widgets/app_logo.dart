import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 120,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo with tooth icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.teal, Color(0xFF00897B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.2),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Tooth icon
              Icon(
                Icons.medical_services_outlined,
                size: size * 0.5,
                color: Colors.white,
              ),
              // Small plus sign overlay
              Positioned(
                bottom: size * 0.15,
                right: size * 0.15,
                child: Container(
                  padding: EdgeInsets.all(size * 0.05),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: size * 0.15,
                    color: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.15),
          // App name
          Text(
            'Dentify',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: size * 0.05),
          // Tagline
          Text(
            'Your Dental Care Companion',
            style: TextStyle(
              fontSize: size * 0.1,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
