import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/rating_service.dart';
import '../../l10n/app_localizations.dart';

class RatingDialog extends StatefulWidget {
  final RatingService ratingService;

  const RatingDialog({super.key, required this.ratingService});

  static Future<void> show(
    BuildContext context,
    RatingService ratingService,
  ) async {
    if (!context.mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => RatingDialog(ratingService: ratingService),
    );
  }

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog>
    with SingleTickerProviderStateMixin {
  int _selectedStars = 5;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onStarTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedStars = index;
    });
  }

  Future<void> _onRate() async {
    HapticFeedback.mediumImpact();
    await widget.ratingService.markAsRated(stars: _selectedStars);
    if (!mounted) return;
    Navigator.of(context).pop();
    await widget.ratingService.openStoreListing();
  }

  Future<void> _onRemindLater() async {
    HapticFeedback.lightImpact();
    await widget.ratingService.remindLater();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _onNeverAskAgain() async {
    HapticFeedback.lightImpact();
    await widget.ratingService.setNeverAskAgain();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocalizations.of(context)!;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        elevation: 16,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header with glowing badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade400,
                      Colors.orange.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),

              const SizedBox(height: 18),

              // Title
              Text(
                s.rateAppTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 10),

              // Description
              Text(
                s.rateAppDescription,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 22),

              // Star Rating Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starNumber = index + 1;
                    final isFilled = starNumber <= _selectedStars;
                    return GestureDetector(
                      onTap: () => _onStarTapped(starNumber),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedScale(
                          scale: isFilled ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            isFilled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: isFilled
                                ? Colors.amber.shade500
                                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            size: 38,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),

              // Rate Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onRate,
                  icon: const Icon(Icons.favorite_rounded, size: 18),
                  label: Text(
                    s.rateNow,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Secondary actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _onNeverAskAgain,
                    child: Text(
                      s.dontAskAgain,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _onRemindLater,
                    child: Text(
                      s.remindMeLater,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

