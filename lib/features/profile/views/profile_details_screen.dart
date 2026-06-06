import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/profile_controller.dart';
import '../../auth/controllers/auth_controller.dart';


class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;

  final _isSaving     = false.obs;
  final _selectedRole = 'Homeowner'.obs;
  final _nameError    = RxnString();

  static const _roles = [
    'Homeowner', 'Contractor', 'Architect', 'Civil Engineer',
    'Developer', 'Interior Designer', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<ProfileController>();
    _nameCtrl  = TextEditingController(text: ctrl.name);
    _emailCtrl = TextEditingController(text: ctrl.email);
    _phoneCtrl = TextEditingController(text: ctrl.phone);
    _cityCtrl  = TextEditingController(text: ctrl.city);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _nameError.value = 'Name cannot be empty';
      return;
    }
    _nameError.value = null;

    final ctrl = Get.find<ProfileController>();
    _isSaving.value = true;
    final ok = await ctrl.saveProfile(
      newName:  _nameCtrl.text,
      newEmail: _emailCtrl.text,
      newPhone: _phoneCtrl.text,
      newCity:  _cityCtrl.text,
    );
    _isSaving.value = false;

    if (ok) {
      Get.snackbar(
        'Profile updated successfully', '',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth    = Get.find<AuthController>();
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final bg      = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        leading: const BackButton(),
        title: Text('Profile Details',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: cs.onSurface)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          children: [
            // ── Avatar section ────────────────────────────────────────────────
            Container(
              color: surface,
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Stack(
                  children: [
                    Obx(() {
                      final user = auth.currentUser.value;
                      return Container(
                        width: 90, height: 90,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: cs.primary.withValues(alpha: 0.25),
                              width: 2),
                        ),
                        child: Text(
                          user?.initials ?? '?',
                          style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: cs.primary),
                        ),
                      );
                    }),
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        width: 28, height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: cs.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_outlined,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Fields ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Obx(() {
                    final err = _nameError.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Field(
                          label: 'Full Name',
                          ctrl: _nameCtrl,
                          hint: 'Ahmed Khan',
                          hasError: err != null,
                          onChanged: (_) {
                            if (_nameError.value != null) _nameError.value = null;
                          },
                        ),
                        if (err != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 2),
                            child: Text(err,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.error)),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'Email',
                    ctrl: _emailCtrl,
                    hint: 'ahmed@email.com',
                    keyboardType: TextInputType.emailAddress,
                    trailing: const Icon(Icons.verified_rounded,
                        size: 16, color: Color(0xFF16A34A)),
                  ),
                  const SizedBox(height: 14),
                  _Field(label: 'Phone Number', ctrl: _phoneCtrl,
                      hint: '+92 3XX XXXXXXX',
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 14),
                  _Field(label: 'City / Location', ctrl: _cityCtrl,
                      hint: 'Lahore, Pakistan'),
                  const SizedBox(height: 14),

                  // Role chips
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Profession / Role',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Wrap(
                        spacing: 8, runSpacing: 8,
                        children: _roles.map((role) {
                          final sel = _selectedRole.value == role;
                          return GestureDetector(
                            onTap: () => _selectedRole.value = role,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: sel ? cs.primary : surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: sel
                                        ? cs.primary
                                        : Theme.of(context).dividerColor),
                              ),
                              child: Text(role,
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: sel
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: sel
                                          ? Colors.white
                                          : cs.onSurface)),
                            ),
                          );
                        }).toList(),
                      )),
                  const SizedBox(height: 14),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Member Since · June 2026',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: cs.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 28),

                  // Save button
                  Obx(() => GestureDetector(
                        onTap: _isSaving.value ? null : _save,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: _isSaving.value
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text('Save Changes',
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final bool hasError;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.keyboardType,
    this.trailing,
    this.hasError = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;
    final errColor = hasError ? cs.error : divider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w500,
                color: hasError ? cs.error : cs.onSurfaceVariant)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                fontSize: 14, color: cs.onSurfaceVariant),
            filled: true,
            fillColor: surface,
            suffixIcon: trailing != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: trailing)
                : null,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: errColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: errColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: hasError ? cs.error : cs.primary, width: 1.5)),
          ),
          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
        ),
      ],
    );
  }
}
