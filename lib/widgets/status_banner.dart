import 'package:flutter/material.dart';

/// Thin strip below the search/region row that shows loading state,
/// API errors, or the current aircraft count.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.count,
  });

  final bool isLoading;
  final String? errorMessage;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (errorMessage != null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(errorMessage!, style: TextStyle(color: colorScheme.onErrorContainer)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          if (isLoading) ...[
            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 8),
            const Text('Updating…'),
          ] else
            Text('$count aircraft tracked', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
