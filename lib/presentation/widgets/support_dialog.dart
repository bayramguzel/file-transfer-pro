import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/support_service.dart';
import '../../core/utils/ad_helper.dart';
import '../../l10n/app_localizations.dart';

class SupportDialog extends StatefulWidget {
  const SupportDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SupportDialog(),
    );
  }

  @override
  State<SupportDialog> createState() => _SupportDialogState();
}

class _SupportDialogState extends State<SupportDialog> {
  bool _isLoadingAd = false;

  String _formatDuration(BuildContext context, Duration duration) {
    final s = AppLocalizations.of(context)!;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return s.hoursMinutesRemaining(hours, minutes);
    }
    return s.minutesRemaining(minutes);
  }

  Future<void> _watchAdAndSupport(BuildContext context) async {
    final supportService = Provider.of<SupportService>(context, listen: false);
    final s = AppLocalizations.of(context)!;

    if (!supportService.canAddMoreTime) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.supportMaxReached),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingAd = true;
    });

    await AdHelper.showRewardedAd(
      onRewarded: () async {
        if (!mounted) return;
        setState(() {
          _isLoadingAd = false;
        });

        // Add 24 hours (capped at 48h)
        await supportService.addSupportHours(24);

        if (!context.mounted) return;
        Navigator.of(context).pop(); // Close support dialog

        // Show celebratory thank you dialog
        _showThankYouDialog(context);
      },
      onFailed: () {
        if (!mounted) return;
        setState(() {
          _isLoadingAd = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.adFailedToLoad),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  static void _showThankYouDialog(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade400,
                    Colors.orange.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.supportThankYouTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              s.supportThankYouMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text(
                s.ok,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppLocalizations.of(context)!;

    return Consumer<SupportService>(
      builder: (context, supportService, child) {
        final isActive = supportService.isSupportActive;
        final remaining = supportService.remainingDuration;
        final canAddMore = supportService.canAddMoreTime;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon with Glow
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isActive
                        ? [Colors.amber.shade400, Colors.orange.shade600]
                        : [
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                            theme.colorScheme.secondary
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isActive ? Colors.amber : theme.colorScheme.primary)
                          .withValues(alpha: 0.3),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isActive ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                s.supportApp,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Status Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? Colors.green.withValues(alpha: 0.4)
                        : Colors.orange.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      size: 16,
                      color: isActive ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive
                          ? s.supportStatusActive
                          : s.supportStatusInactive,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Time remaining or explanation
              if (isActive) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        s.supportRemainingTime(
                          _formatDuration(context, remaining),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        canAddMore
                            ? s.supportDescription
                            : s.supportMaxReached,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.75),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  s.supportDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),

              // Watch Ad Button
              if (_isLoadingAd) ...[
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      s.adLoading,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canAddMore
                        ? () => _watchAdAndSupport(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.play_circle_outline_rounded),
                    label: Text(
                      s.supportExtend,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(s.cancel),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
