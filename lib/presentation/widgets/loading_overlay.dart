import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';

/// Loading overlay widget with optional progress indicator
class LoadingOverlay extends StatelessWidget {
  final String message;
  final double? progress; // 0.0 to 1.0, null for indeterminate

  const LoadingOverlay({
    super.key,
    required this.message,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (progress != null)
                  CircularProgressIndicator(value: progress)
                else
                  const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: context.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${(progress! * 100).toInt()}%',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
