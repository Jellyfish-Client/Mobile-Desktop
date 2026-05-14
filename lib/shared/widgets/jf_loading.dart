import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'jf_logo.dart';

class JfLoading extends StatelessWidget {
  const JfLoading({this.message, this.logoSize = 96, super.key});

  final String? message;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          JfLogo(size: logoSize),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
