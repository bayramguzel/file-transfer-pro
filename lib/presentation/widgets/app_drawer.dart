import 'rating_dialog.dart';
import '../../core/services/rating_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/enums.dart' as enums;
import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_event.dart';
import '../blocs/settings/settings_state.dart';
import 'support_dialog.dart';
import '../../l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      child: SafeArea(
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // Premium Header with Profile
                _buildPremiumHeader(context, theme, state),

                const SizedBox(height: 8),

                // Home
                _buildMenuItem(
                  context: context,
                  icon: Icons.home_rounded,
                  title: s.home,
                  onTap: () => Navigator.pop(context),
                  theme: theme,
                ),

                _buildDivider(theme),

                // Profile Section
                _buildExpandableSection(
                  context: context,
                  icon: Icons.person_rounded,
                  title: s.profile,
                  theme: theme,
                  children: [
                    _buildProfileSection(context, theme, state),
                  ],
                ),

                // Appearance Section
                _buildExpandableSection(
                  context: context,
                  icon: Icons.palette_rounded,
                  title: s.appearance,
                  theme: theme,
                  children: [
                    _buildAppearanceSection(context, theme, state),
                  ],
                ),

                // Language Section
                _buildExpandableSection(
                  context: context,
                  icon: Icons.language_rounded,
                  title: s.language,
                  theme: theme,
                  children: [
                    _buildLanguageSection(context, theme, state),
                  ],
                ),

                // Storage Section
                _buildExpandableSection(
                  context: context,
                  icon: Icons.storage_rounded,
                  title: s.storage,
                  theme: theme,
                  children: [
                    _buildStorageSection(context, theme, state),
                  ],
                ),

                // Support App
                _buildMenuItem(
                  context: context,
                  icon: Icons.star_rounded,
                  title: s.supportApp,
                  onTap: () {
                    Navigator.pop(context);
                    SupportDialog.show(context);
                  },
                  theme: theme,
                  iconColor: Colors.amber,
                ),

                // Rate 5 Stars
                _buildMenuItem(
                  context: context,
                  icon: Icons.rate_review_rounded,
                  title: s.rateAppTitle,
                  onTap: () {
                    Navigator.pop(context);
                    RatingDialog.show(
                      context,
                      context.read<RatingService>(),
                    );
                  },
                  theme: theme,
                  iconColor: Colors.amber.shade600,
                ),

                _buildDivider(theme),

                // About Section
                _buildExpandableSection(
                  context: context,
                  icon: Icons.info_outline_rounded,
                  title: s.about,
                  theme: theme,
                  children: [
                    _buildAboutSection(context, theme),
                  ],
                ),

                // Privacy Policy
                _buildMenuItem(
                  context: context,
                  icon: Icons.privacy_tip_outlined,
                  title: s.privacyPolicy,
                  onTap: () => _openUrl(
                      'https://www.41software.com/privacy/privacy_filetransfer.php'),
                  theme: theme,
                ),

                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(
      BuildContext context, ThemeData theme, SettingsState state) {
    final s = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile Picture with Edit Button
              Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: state.profilePicturePath != null
                          ? Image.file(
                              File(state.profilePicturePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildDefaultAvatar(theme),
                            )
                          : _buildDefaultAvatar(theme),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickProfilePicture(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.username.isNotEmpty ? state.username : s.user,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            s.proUser,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.deviceName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone_android_rounded,
                              color: Colors.white.withValues(alpha: 0.8), size: 13),
                          const SizedBox(width: 4),
                          Text(
                            state.deviceName,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz_rounded,
                    color: Colors.white.withValues(alpha: 0.9), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.appTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        s.appSubtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(ThemeData theme) {
    return Container(
      color: Colors.white.withValues(alpha: 0.2),
      child: const Icon(Icons.person_rounded, size: 40, color: Colors.white),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
    Color? iconColor,
  }) {
    final effectiveColor = iconColor ?? theme.colorScheme.primary;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: effectiveColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      onTap: onTap,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
    );
  }

  Widget _buildExpandableSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: children,
      ),
    );
  }

  Widget _buildProfileSection(
      BuildContext context, ThemeData theme, SettingsState state) {
    final s = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Picture Preview
        Center(
          child: GestureDetector(
            onTap: () => _pickProfilePicture(context),
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: state.profilePicturePath != null
                        ? Image.file(
                            File(state.profilePicturePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              child: Icon(Icons.person_rounded,
                                  size: 50, color: theme.colorScheme.primary),
                            ),
                          )
                        : Container(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            child: Icon(Icons.person_rounded,
                                size: 50, color: theme.colorScheme.primary),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () => _pickProfilePicture(context),
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: Text(s.changePhoto),
          ),
        ),
        if (state.profilePicturePath != null)
          Center(
            child: TextButton.icon(
              onPressed: () {
                context
                    .read<SettingsBloc>()
                    .add(const UpdateProfilePicture(null));
              },
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 16, color: Colors.red),
              label: Text(s.removePhoto,
                  style: const TextStyle(color: Colors.red)),
            ),
          ),
        const SizedBox(height: 16),

        // Username Field
        Text(
          s.profileName,
          style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: state.username)
            ..selection =
                TextSelection.collapsed(offset: state.username.length),
          decoration: InputDecoration(
            hintText: s.enterName,
            prefixIcon:
                Icon(Icons.badge_rounded, color: theme.colorScheme.primary),
            filled: true,
            fillColor: theme.colorScheme.primary.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              context.read<SettingsBloc>().add(UpdateUsername(value));
            }
          },
        ),
        const SizedBox(height: 8),
        Text(
          '💡 ${s.displayNameNote}',
          style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 16),

        // Device Name Field
        Text(
          s.deviceName,
          style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: state.deviceName)
            ..selection =
                TextSelection.collapsed(offset: state.deviceName.length),
          decoration: InputDecoration(
            hintText: 'Galaxy S24, MacBook...',
            prefixIcon:
                Icon(Icons.phone_android_rounded, color: theme.colorScheme.primary),
            filled: true,
            fillColor: theme.colorScheme.primary.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
          onChanged: (value) {
            context.read<SettingsBloc>().add(UpdateDeviceName(value));
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(
      BuildContext context, ThemeData theme, SettingsState state) {
    final s = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Theme Mode
        Text(
          s.theme,
          style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _buildThemeOption(
                context: context,
                theme: theme,
                icon: Icons.light_mode_rounded,
                label: s.themeLight,
                isSelected: state.themeMode == enums.ThemeMode.light,
                onTap: () => context
                    .read<SettingsBloc>()
                    .add(const UpdateThemeMode(enums.ThemeMode.light)),
              ),
              _buildThemeOption(
                context: context,
                theme: theme,
                icon: Icons.dark_mode_rounded,
                label: s.themeDark,
                isSelected: state.themeMode == enums.ThemeMode.dark,
                onTap: () => context
                    .read<SettingsBloc>()
                    .add(const UpdateThemeMode(enums.ThemeMode.dark)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Accent Color
        Text(
          s.accentColor,
          style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: enums.AccentColor.values.map((color) {
            final isSelected = state.accentColor == color;
            return GestureDetector(
              onTap: () =>
                  context.read<SettingsBloc>().add(UpdateAccentColor(color)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getColorForAccent(color),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _getColorForAccent(color)
                                .withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 24)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary
                  ])
                : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSection(
      BuildContext context, ThemeData theme, SettingsState state) {
    final s = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildLanguageOption(
          context: context,
          theme: theme,
          flag: '🇹🇷',
          name: s.turkish,
          language: enums.Language.tr,
          isSelected: state.language == enums.Language.tr,
        ),
        const SizedBox(height: 8),
        _buildLanguageOption(
          context: context,
          theme: theme,
          flag: '🇬🇧',
          name: s.english,
          language: enums.Language.en,
          isSelected: state.language == enums.Language.en,
        ),
        const SizedBox(height: 8),
        _buildLanguageOption(
          context: context,
          theme: theme,
          flag: '🇩🇪',
          name: s.german,
          language: enums.Language.de,
          isSelected: state.language == enums.Language.de,
        ),
      ],
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required ThemeData theme,
    required String flag,
    required String name,
    required enums.Language language,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        // Dil değişikliğini uygula
        context.read<SettingsBloc>().add(UpdateLanguage(language));

        // Drawer'ı kapat
        Navigator.of(context).pop();

        // Kısa bir gecikme ile uygulamanın yeniden render olmasını sağla
        Future.delayed(const Duration(milliseconds: 100), () {
          // Uygulamanın yeniden yüklenmesini tetikle
          if (context.mounted) {
            // Ana sayfaya geri dön ve state'i yenile
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary
                ])
              : null,
          color: isSelected
              ? null
              : theme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, ThemeData theme) {
    final s = AppLocalizations.of(context)!;
    return Column(
      children: [
        // App Info Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.secondary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.swap_horiz_rounded,
                    size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                s.appTitle,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '${s.version} 1.0.0',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _openUrl('https://www.41software.com'),
                child: Text(
                  'www.41software.com',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Feedback Button
        _buildActionButton(
          theme: theme,
          icon: Icons.email_outlined,
          label: s.feedback,
          onTap: () => _openUrl(
              'mailto:info@41software.com?subject=File Transfer - Feedback'),
        ),
        const SizedBox(height: 12),

        // Social Media
        Text(
          s.followUs,
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSocialButton(
                icon: Icons.play_circle_outline,
                label: 'YouTube',
                url: 'https://www.youtube.com/@41softwarecom',
                color: Colors.red),
            _buildSocialButton(
                icon: Icons.camera_alt_outlined,
                label: 'Instagram',
                url: 'https://www.instagram.com/41software',
                color: const Color(0xFFE4405F)),
            _buildSocialButton(
                icon: Icons.tag,
                label: 'Twitter',
                url: 'https://twitter.com/41software',
                color: const Color(0xFF1DA1F2)),
            _buildSocialButton(
                icon: Icons.music_note,
                label: 'TikTok',
                url: 'https://www.tiktok.com/@41software',
                color: Colors.black),
          ],
        ),
        const SizedBox(height: 16),

        // Donation
        Text(
          s.supportUs,
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDonationButton(
                icon: Icons.coffee_outlined,
                label: 'Coffee',
                url: 'https://www.buymeacoffee.com/41software',
                color: const Color(0xFFFFDD00),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDonationButton(
                icon: Icons.payment_outlined,
                label: 'PayPal',
                url: 'https://www.paypal.me/asbaypc',
                color: const Color(0xFF0070BA),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _openUrl(url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationButton({
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _openUrl(url),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13, color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProfilePicture(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final s = AppLocalizations.of(context)!;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.photo_library_rounded,
                        color: theme.colorScheme.primary),
                  ),
                  title: Text(s.gallery,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _imgFromGallery(context);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.camera_alt_rounded,
                        color: theme.colorScheme.secondary),
                  ),
                  title: Text(s.camera,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _imgFromCamera(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _savePermanentAvatar(String sourcePath) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final ext = sourcePath.split('.').last;
      final destPath = '${docDir.path}/user_profile_avatar.$ext';
      final sourceFile = File(sourcePath);
      final targetFile = File(destPath);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await sourceFile.copy(destPath);
      return destPath;
    } catch (e) {
      return sourcePath;
    }
  }

  Future<void> _imgFromGallery(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null && context.mounted) {
      final permanentPath = await _savePermanentAvatar(result.files.single.path!);
      if (context.mounted) {
        context
            .read<SettingsBloc>()
            .add(UpdateProfilePicture(permanentPath));
      }
    }
  }

  Future<void> _imgFromCamera(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null && context.mounted) {
        final permanentPath = await _savePermanentAvatar(image.path);
        if (context.mounted) {
          context.read<SettingsBloc>().add(UpdateProfilePicture(permanentPath));
        }
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
    }
  }

  Widget _buildStorageSection(
      BuildContext context, ThemeData theme, SettingsState state) {
    final s = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.downloadDirectory,
          style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            state.downloadDirectory ??
                context.read<SettingsBloc>().repository.getEffectiveDownloadDirectory(),
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // iOS'ta uygulama sanal alanı nedeniyle klasör seçilemez;
            // dosyalar Dosyalar uygulamasındaki uygulama klasöründe tutulur.
            if (!Platform.isIOS)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickDownloadDirectory(context),
                  icon: const Icon(Icons.folder_open_rounded, size: 18),
                  label: Text(s.changePath),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            if (state.downloadDirectory != null || Platform.isIOS) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () =>
                    _openDownloadFolder(state.downloadDirectory ?? ''),
                icon: const Icon(Icons.launch_rounded),
                tooltip: s.openFolder,
                style: IconButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _pickDownloadDirectory(BuildContext context) async {
    try {
      String? result = await FilePicker.platform.getDirectoryPath();
      if (result != null && context.mounted) {
        context.read<SettingsBloc>().add(UpdateDownloadDirectory(result));
      }
    } catch (e) {
      debugPrint('Error picking directory: $e');
    }
  }

  Future<void> _openDownloadFolder(String path) async {
    try {
      if (Platform.isIOS) {
        // iOS'ta indirilenler Dosyalar uygulamasındaki uygulama
        // klasöründe görünür.
        final filesUri = Uri.parse('shareddocuments://');
        if (await canLaunchUrl(filesUri)) {
          await launchUrl(filesUri);
          return;
        }
      }
      final Directory dir = Directory(path);
      if (await dir.exists()) {
        await launchUrl(Uri.parse('file:$path'),
            mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening folder: $e');
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error opening URL: $e');
    }
  }

  Color _getColorForAccent(enums.AccentColor accent) {
    switch (accent) {
      case enums.AccentColor.blue:
        return const Color(0xFF3B82F6);
      case enums.AccentColor.green:
        return const Color(0xFF22C55E);
      case enums.AccentColor.purple:
        return const Color(0xFFA855F7);
      case enums.AccentColor.orange:
        return const Color(0xFFF97316);
      case enums.AccentColor.teal:
        return const Color(0xFF14B8A6);
    }
  }
}
