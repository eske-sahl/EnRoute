import 'package:flutter/material.dart';

class AppCreatorFooter extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const AppCreatorFooter({
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 20),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: padding,
      child: Center(
        child: Opacity(
          opacity: 0.38,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, size: 10, color: textColor),
                  const SizedBox(width: 5),
                  Text(
                    'Created by Sahl Saleem & Fathima Riyas',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'EnRoute • Smart Kerala Transit System',
                style: TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 0.3,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
