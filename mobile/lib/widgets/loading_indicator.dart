import 'package:flutter/material.dart';
import 'package:aqua_sense/utils/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool useScaffold;
  final Color? color;

  const LoadingIndicator({
    Key? key, 
    this.message, 
    this.useScaffold = true,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? AppTheme.primaryColor,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );

    return useScaffold ? Scaffold(body: content) : content;
  }
}

