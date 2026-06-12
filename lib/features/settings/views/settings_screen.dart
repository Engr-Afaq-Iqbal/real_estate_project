import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../controllers/settings_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../presentation/routes/app_routes.dart';

// _kDanger stays const — it's a semantic status color, not a theme token
const _kDanger = Color(0xFFDC2626);

// POLISH 4: Simulated push notification banner
void _showTestNotification(BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _NotificationBanner(
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
  // Auto-dismiss after 4 seconds
  Future.delayed(const Duration(seconds: 4), () {
    if (entry.mounted) entry.remove();
  });
}

class _NotificationBanner extends StatefulWidget {
  final VoidCallback onDismiss;
  const _NotificationBanner({required this.onDismiss});

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(
            begin: const Offset(0, -1.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Positioned(
      top: top + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onDismiss,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(14),
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.construction_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BuildOS',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Text(
                          'Foundation stage updated to 75% by Supervisor Ahmed',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.85)),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('now',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.5))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SettingsController>();
    final auth = Get.find<AuthController>();
    final cs   = Theme.of(context).colorScheme;
    final bg   = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        title: Text('Settings',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: cs.onSurface)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 48),
        children: [
          const SizedBox(height: 16),
          _ProfileCard(),
          const SizedBox(height: 24),

          _SectionHeader('APPEARANCE'),
          _Group(children: [
            _AppearanceThemeRow(ctrl: ctrl),
            const _Divider(),
            _AppThemeModeRow(ctrl: ctrl),
          ]),
          const SizedBox(height: 24),

          _SectionHeader('LANGUAGE'),
          _Group(children: [
            // PK6: Urdu toggle is hidden behind "Coming Soon" until all strings are translated
            _NavigationRow(
              icon: Icons.language_rounded,
              label: 'App Language',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('اردو Coming Soon 🔜',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFF59E0B))),
                  ),
                  const SizedBox(width: 6),
                  Text('English', style: _trailingStyle(context)),
                ],
              ),
              // Tap shows info instead of toggling
              onTap: () => Get.snackbar(
                'اردو Coming Soon',
                'Full Urdu interface is being prepared. '
                'It will be available in the next update. / '
                'اردو زبان جلد آ رہی ہے۔',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
              ),
            ),
          ]),
          const SizedBox(height: 24),

          _SectionHeader('PROJECT'),
          _Group(children: [
            _NavigationRow(
              icon: Icons.payments_outlined,
              label: 'Default Currency',
              trailing: Obx(() => Text(ctrl.defaultCurrency.value,
                  style: _trailingStyle(context))),
            ),
            const _Divider(),
            _MeasurementRow(ctrl: ctrl),
            const _Divider(),
            const _NavigationRow(
                icon: Icons.notifications_outlined, label: 'Notifications'),
          ]),
          const SizedBox(height: 24),

          _SectionHeader('NOTIFICATIONS'),
          Obx(() => _Group(children: [
                _ToggleRow(
                  icon: Icons.notifications_active_outlined,
                  label: 'Push Notifications',
                  value: ctrl.notificationsEnabled.value,
                  onChanged: ctrl.setNotificationsEnabled,
                ),
                const _Divider(),
                _ToggleRow(
                  icon: Icons.email_outlined,
                  label: 'Email Notifications',
                  value: ctrl.emailNotifications.value,
                  onChanged: ctrl.setEmailNotifications,
                ),
                const _Divider(),
                _ToggleRow(
                  icon: Icons.construction_outlined,
                  label: 'Project Update Alerts',
                  value: ctrl.projectUpdateAlerts.value,
                  onChanged: ctrl.setProjectUpdateAlerts,
                ),
                const _Divider(),
                _ToggleRow(
                  icon: Icons.sms_outlined,
                  label: 'SMS Alerts',
                  value: ctrl.smsAlerts.value,
                  onChanged: ctrl.setSmsAlerts,
                ),
              ])),
          const SizedBox(height: 12),
          // POLISH 4: Test notification button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _Group(children: [
              _NavigationRow(
                icon: Icons.notifications_none_rounded,
                label: 'Test Notification',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Demo',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E3A8A))),
                ),
                onTap: () => _showTestNotification(context),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          _SectionHeader('SECURITY'),
          Obx(() => _Group(children: [
                _ToggleRow(
                  icon: Icons.fingerprint_rounded,
                  label: 'Biometric Login',
                  value: ctrl.biometricEnabled.value,
                  onChanged: (v) => ctrl.biometricEnabled.value = v,
                ),
                const _Divider(),
                const _NavigationRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Change Password',
                ),
                const _Divider(),
                _NavigationRow(
                  icon: Icons.security_rounded,
                  label: 'Two-Factor Auth',
                  trailing: Text(
                    ctrl.twoFactorEnabled.value ? 'On' : 'Off',
                    style: _trailingStyle(context).copyWith(
                        color: ctrl.twoFactorEnabled.value
                            ? _primaryText(context)
                            : cs.onSurfaceVariant),
                  ),
                ),
              ])),
          const SizedBox(height: 24),

          _SectionHeader('ABOUT'),
          _Group(children: [
            const _VersionRow(),
            const _Divider(),
            const _NavigationRow(
                icon: Icons.article_outlined, label: 'Terms of Service'),
            const _Divider(),
            const _NavigationRow(
                icon: Icons.privacy_tip_outlined, label: 'Privacy Policy'),
            const _Divider(),
            const _NavigationRow(
                icon: Icons.help_outline_rounded, label: 'Help & Support'),
            const _Divider(),
            const _NavigationRow(
                icon: Icons.star_outline_rounded, label: 'Rate the App'),
          ]),
          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _DangerButton(
                  icon: Icons.logout_rounded,
                  label: 'Log Out',
                  onTap: () => _confirmLogout(context, auth),
                ),
                const SizedBox(height: 12),
                _DangerButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete Account',
                  onTap: () => _confirmDeleteAccount(context, ctrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthController auth) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: divider, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.logout_rounded, size: 40, color: _kDanger),
            const SizedBox(height: 14),
            Text('Log Out?',
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            const SizedBox(height: 8),
            Text('You will be returned to the login screen.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14, color: cs.onSurfaceVariant)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                      label: 'Cancel', onTap: Get.back, outlined: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SheetButton(
                    label: 'Log Out',
                    onTap: () { Get.back(); auth.logout(); },
                    danger: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, SettingsController ctrl) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    HapticFeedback.heavyImpact();
    ctrl.deleteConfirmText.value = '';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                    color: _kDanger.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded,
                    size: 28, color: _kDanger),
              ),
              const SizedBox(height: 14),
              Text('Delete Account?',
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: cs.onSurface)),
              const SizedBox(height: 10),
              Text(
                'This will permanently delete your account and all project data. '
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Type DELETE to confirm',
                  labelStyle: GoogleFonts.inter(
                      fontSize: 13, color: cs.onSurfaceVariant),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: divider)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: divider)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: _kDanger, width: 1.5)),
                ),
                onChanged: (v) => ctrl.deleteConfirmText.value = v,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SheetButton(
                        label: 'Cancel', onTap: Get.back, outlined: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => _SheetButton(
                          label: ctrl.isDeleting.value
                              ? 'Deleting...'
                              : 'Delete My Account',
                          onTap: ctrl.canConfirmDelete
                              ? ctrl.deleteAccount
                              : null,
                          danger: true,
                          loading: ctrl.isDeleting.value,
                        )),
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

// ── Profile card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth    = Get.find<AuthController>();
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.profileDetails),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: cs.onSurface.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Obx(() {
            final user = auth.currentUser.value;
            return Row(
              children: [
                Container(
                  width: 52, height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    user?.initials ?? '?',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _primaryText(context)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'User',
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w700,
                              color: cs.onSurface)),
                      const SizedBox(height: 3),
                      Text(user?.email ?? '',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: cs.onSurfaceVariant)),
                      const SizedBox(height: 5),
                      Text('Edit Profile →',
                          style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: _primaryText(context))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant, size: 20),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ── Appearance rows ───────────────────────────────────────────────────────────

class _AppearanceThemeRow extends StatelessWidget {
  final SettingsController ctrl;
  const _AppearanceThemeRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.palette_outlined,
                      size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Theme Color',
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w500,
                            color: cs.onSurface)),
                  ),
                  Text(ctrl.selectedColorName,
                      style: _trailingStyle(context)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ctrl.themeColors.asMap().entries.map((e) {
                  final i   = e.key;
                  final col = e.value;
                  final sel = ctrl.selectedThemeColor.value == i;
                  return GestureDetector(
                    onTap: () => ctrl.setThemeColor(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: col,
                        shape: BoxShape.circle,
                        border: Border.all(
                          // Use onSurface so the selection ring is visible
                          // in both light and dark mode
                          color: sel ? cs.onSurface : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: sel
                            ? [BoxShadow(
                                color: col.withValues(alpha: 0.4),
                                blurRadius: 6)]
                            : [],
                      ),
                      child: sel
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ));
  }
}

class _AppThemeModeRow extends StatelessWidget {
  final SettingsController ctrl;
  const _AppThemeModeRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.brightness_6_outlined,
              size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text('App Theme',
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: cs.onSurface)),
          ),
          _ModeChips(ctrl: ctrl),
        ],
      ),
    );
  }
}

class _ModeChips extends StatelessWidget {
  final SettingsController ctrl;
  const _ModeChips({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    const modes   = ['Light', 'Dark', 'System'];
    final keys    = ['light', 'dark', 'system'];
    // Inactive bg that works in both modes
    final inactiveBg = cs.onSurface.withValues(alpha: 0.06);

    return Obx(() => Row(
          children: List.generate(modes.length, (i) {
            final sel = ctrl.themeMode.value == keys[i];
            return GestureDetector(
              onTap: () => ctrl.setThemeMode(keys[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: sel ? cs.primary : inactiveBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(modes[i],
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: sel ? Colors.white : cs.onSurfaceVariant)),
              ),
            );
          }),
        ));
  }
}

// ── Measurement row ───────────────────────────────────────────────────────────

class _MeasurementRow extends StatelessWidget {
  final SettingsController ctrl;
  const _MeasurementRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs         = Theme.of(context).colorScheme;
    final inactiveBg = cs.onSurface.withValues(alpha: 0.06);
    const units      = ['Marla', 'Kanal', 'Sq.ft', 'Sq.yd'];

    return Obx(() => Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.square_foot_outlined,
                  size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Measurement Units',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500,
                        color: cs.onSurface)),
              ),
              Row(
                children: units.map((u) {
                  final sel = ctrl.measurementUnit.value == u;
                  return GestureDetector(
                    onTap: () => ctrl.setMeasurementUnit(u),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: sel ? cs.primary : inactiveBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(u,
                          style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w500,
                              color: sel ? Colors.white : cs.onSurfaceVariant)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ));
  }
}

// ── Version row ───────────────────────────────────────────────────────────────

class _VersionRow extends StatelessWidget {
  const _VersionRow();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (_, snap) {
        final version = snap.data?.version ?? '1.0.0';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Version',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500,
                        color: cs.onSurface)),
              ),
              Text(version, style: _trailingStyle(context)),
            ],
          ),
        );
      },
    );
  }
}

// ── Danger zone buttons ───────────────────────────────────────────────────────

class _DangerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DangerButton({
    required this.icon, required this.label, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _kDanger.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: _kDanger),
              const SizedBox(width: 8),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: _kDanger)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom sheet button ───────────────────────────────────────────────────────

class _SheetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final bool danger;
  final bool loading;

  const _SheetButton({
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.danger   = false,
    this.loading  = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;
    final color   = danger ? _kDanger : cs.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(10),
          border: outlined ? Border.all(color: divider) : null,
        ),
        child: loading
            ? SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: outlined ? cs.onSurfaceVariant : Colors.white))
            : Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: outlined ? cs.onSurfaceVariant : Colors.white)),
      ),
    );
  }
}

// ── Reusable list building blocks ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: cs.onSurface.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 44),
        child: Divider(
            height: 1, color: Theme.of(context).dividerColor),
      );
}

class _NavigationRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _NavigationRow({
    this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w500,
                      color: cs.onSurface)),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool value;
  final void Function(bool) onChanged;

  const _ToggleRow({
    this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: cs.onSurface)),
          ),
          // Switch uses theme's switchTheme — no activeColor override needed
          // since AppTheme already wires the primary color into switchTheme
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// ── Trailing style helper (context-aware) ─────────────────────────────────────
TextStyle _trailingStyle(BuildContext context) => GoogleFonts.inter(
    fontSize: 13,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
    fontWeight: FontWeight.w400);

// ── Primary text colour helper ────────────────────────────────────────────────
// In light mode the primary color (dark navy) is readable on white surfaces.
// In dark mode that same dark navy is invisible on dark surfaces → use white.
Color _primaryText(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Theme.of(context).colorScheme.primary;
