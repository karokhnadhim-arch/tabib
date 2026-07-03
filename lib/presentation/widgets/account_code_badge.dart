import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// Read-only display chip for a permanent provider account code.
class AccountCodeBadge extends StatelessWidget {
  const AccountCodeBadge({
    super.key,
    required this.code,
    this.compact = false,
    this.onCopy,
  });

  final String code;
  final bool compact;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryDark.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.badge_outlined,
            size: compact ? 14 : 16,
            color: AppTheme.primaryDark,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              code,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: compact ? 12 : 13,
                color: AppTheme.primaryDark,
                letterSpacing: 0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onCopy != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onCopy,
              child: Icon(
                Icons.copy,
                size: compact ? 14 : 16,
                color: AppTheme.primaryDark.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
    return child;
  }

  static void copyToClipboard(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(code)),
    );
  }
}
