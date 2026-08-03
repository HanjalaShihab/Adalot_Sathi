import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/profile/profile_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user.dart';

/// Profile screen: personal, professional, security, preferences, subscription,
/// statistics, data, and account management.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () => ref.read(authControllerProvider.notifier).refreshUser(),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 40),
                children: [
                  const SizedBox(height: 16),
                  _ProfileHeader(user: user),
                  const SizedBox(height: 20),
                  _SubscriptionCard(user: user),
                  const SizedBox(height: 16),
                  _StatisticsCard(user: user),
                  const SizedBox(height: 16),
                  _PersonalSection(user: user),
                  const SizedBox(height: 16),
                  _ProfessionalSection(user: user),
                  const SizedBox(height: 16),
                  _SecuritySection(),
                  const SizedBox(height: 16),
                  _PreferencesSection(user: user),
                  const SizedBox(height: 16),
                  _DataSection(),
                  const SizedBox(height: 16),
                  _AccountSection(context: context, ref: ref, user: user),
                  const SizedBox(height: 20),
                  const Text(
                    'Adalot Sathi v1.0.0\nআদালত সাথী — Legal Case Deadline Manager',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = user.name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0])
        .take(2)
        .join()
        .toUpperCase();

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primary,
          child: Text(
            initials,
            style: const TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        if (user.phone != null && user.phone!.isNotEmpty)
          Text(
            user.phone!,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        if (user.chamberName != null && user.chamberName!.isNotEmpty)
          Text(
            user.chamberName!,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
      ],
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final User user;
  const _SubscriptionCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isPaid = user.isPaid;
    final used = user.subscription.activeCasesCount;
    final limit = user.subscription.activeCaseLimit;
    final remaining = user.subscription.remainingActiveSlots;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPaid ? Icons.workspace_premium : Icons.lock_outline,
                  color: isPaid ? AppColors.accent : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  isPaid ? 'Pro Plan' : 'Free Plan',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const Spacer(),
                if (isPaid)
                  _Badge(text: 'ACTIVE', color: AppColors.success)
                else
                  _Badge(text: 'FREE', color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            if (isPaid) ...[
              const Text(
                'Unlimited active cases · Push + SMS reminders',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              if (user.subscriptionExpiresAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Expires ${DateFormat('d MMM yyyy').format(DateTime.parse(user.subscriptionExpiresAt!))}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
            ] else ...[
              const Text(
                'Push reminders on up to 5 active cases',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              if (limit != null && limit > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: used / limit,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceAlt,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                '$used of $limit active cases used · $remaining slot${remaining == 1 ? '' : 's'} left',
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Upgrade flow is coming soon.')),
                      );
                    },
                    icon: const Icon(Icons.workspace_premium),
                    label: const Text('Upgrade Plan'),
                  ),
                ),
                if (isPaid) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cancel subscription flow is coming soon.')),
                        );
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment history coming soon.')),
                );
              },
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: const Text('Payment History'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  final User user;
  const _StatisticsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final active = user.subscription.activeCasesCount;
    // Placeholder stats; real counts come from the cases endpoint.
    const total = 0, closed = 0, upcoming = 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _StatTile(icon: Icons.folder_outlined, label: 'Total', value: '$total'),
                _StatTile(icon: Icons.trending_up, label: 'Active', value: '$active'),
                _StatTile(icon: Icons.check_circle_outline, label: 'Closed', value: '$closed'),
                _StatTile(icon: Icons.event_outlined, label: 'Upcoming', value: '$upcoming'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PersonalSection extends ConsumerWidget {
  final User user;
  const _PersonalSection({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = TextEditingController(text: user.name);
    final email = TextEditingController(text: user.email);
    final phone = TextEditingController(text: user.phone ?? '');
    final barCouncil = TextEditingController(text: user.barCouncilNumber ?? '');
    final chamber = TextEditingController(text: user.chamberName ?? '');
    final address = TextEditingController(text: user.address ?? '');
    final district = TextEditingController(text: user.district ?? '');
    final formKey = GlobalKey<FormState>();
    final profileState = ref.watch(profileControllerProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),
              _field(name, 'Full Name *', validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null),
              const SizedBox(height: 12),
              _field(email, 'Email Address *', keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) return 'Enter a valid email';
                    return null;
                  }),
              const SizedBox(height: 12),
              _field(phone, 'Phone Number', keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    if (!RegExp(r'^01[3-9][0-9]{8}$').hasMatch(v.trim())) return 'Enter a valid Bangladeshi number';
                    return null;
                  }),
              const SizedBox(height: 12),
              _field(barCouncil, 'Bar Council Registration Number (optional)'),
              const SizedBox(height: 12),
              _field(chamber, 'Chamber / Law Firm Name'),
              const SizedBox(height: 12),
              _field(address, 'Address', maxLines: 2),
              const SizedBox(height: 12),
              _field(district, 'District'),
              const SizedBox(height: 16),
              _ProfilePhotoPicker(),
              const SizedBox(height: 16),
              if (profileState.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    profileState.error!,
                    style: const TextStyle(color: AppColors.danger, fontSize: 13),
                  ),
                ),
              if (profileState.successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    profileState.successMessage!,
                    style: const TextStyle(color: AppColors.success, fontSize: 13),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: profileState.isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final ok = await ref.read(profileControllerProvider.notifier).updateProfile(
                                name: name.text.trim(),
                                email: email.text.trim(),
                                phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
                                barCouncilNumber: barCouncil.text.trim().isEmpty ? null : barCouncil.text.trim(),
                                chamberName: chamber.text.trim().isEmpty ? null : chamber.text.trim(),
                                address: address.text.trim().isEmpty ? null : address.text.trim(),
                                district: district.text.trim().isEmpty ? null : district.text.trim(),
                              );
                          if (ok) {
                            ref.read(authControllerProvider.notifier).refreshUser();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile updated successfully.')),
                              );
                            }
                          }
                        },
                  child: profileState.isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.textOnPrimary),
                        )
                      : const Text('Save Personal Info'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfessionalSection extends ConsumerWidget {
  final User user;
  const _ProfessionalSection({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experience = TextEditingController(text: user.yearsOfExperience?.toString() ?? '');
    final preferredCourt = TextEditingController(text: user.preferredCourt ?? '');
    final formKey = GlobalKey<FormState>();

    // Practice areas (multi-select chips).
    final allAreas = ['Criminal', 'Civil', 'Family', 'Corporate', 'Property', 'Tax', 'Labour', 'Banking', 'Other'];
    final selected = <String>[...user.practiceAreas];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Professional Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),
              _field(experience, 'Years of Experience', keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 0 || n > 100) return 'Enter a valid number (0–100)';
                    return null;
                  }),
              const SizedBox(height: 12),
              _field(preferredCourt, 'Preferred Court'),
              const SizedBox(height: 14),
              const Text('Primary Practice Areas',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allAreas.map((area) {
                  final isSelected = selected.contains(area);
                  return FilterChip(
                    label: Text(area),
                    selected: isSelected,
                    onSelected: (sel) {
                      if (sel) {
                        selected.add(area);
                      } else {
                        selected.remove(area);
                      }
                      // Rebuild to reflect selection.
                      (context as Element).markNeedsBuild();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final ok = await ref.read(profileControllerProvider.notifier).updateProfile(
                          yearsOfExperience: int.tryParse(experience.text.trim()),
                          preferredCourt: preferredCourt.text.trim().isEmpty ? null : preferredCourt.text.trim(),
                          practiceAreas: selected,
                        );
                    if (ok) {
                      ref.read(authControllerProvider.notifier).refreshUser();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Professional info saved.')),
                        );
                      }
                    }
                  },
                  child: const Text('Save Professional Info'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecuritySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final password = TextEditingController();
    final confirm = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Security',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),
              _field(password, 'Change Password', obscure: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (v.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  }),
              const SizedBox(height: 12),
              _field(confirm, 'Confirm Password', obscure: true,
                  validator: (v) => (v != password.text) ? 'Passwords do not match' : null),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    if (password.text.isEmpty) return;
                    final ok = await ref.read(profileControllerProvider.notifier).updateProfile(
                          password: password.text,
                        );
                    if (ok && context.mounted) {
                      password.clear();
                      confirm.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password changed successfully.')),
                      );
                    }
                  },
                  child: const Text('Change Password'),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 20, color: AppColors.textSecondary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Two-step verification (coming soon)',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferencesSection extends ConsumerWidget {
  final User user;
  const _PreferencesSection({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = user.appLanguage == 'bn'
        ? 'বাংলা (Bangla)'
        : 'English';
    var notifications = true;
    var reminders = true;
    var darkMode = user.darkMode;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preferences',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bangla is the primary/default language. The app supports Bangla perfectly.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                _prefRow(Icons.language, 'App Language', language,
                    onTap: () => ref.read(profileControllerProvider.notifier).updateProfile(
                          appLanguage: 'bn',
                        )),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Notification Settings', style: TextStyle(fontSize: 14)),
                  value: notifications,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => notifications = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reminder Settings', style: TextStyle(fontSize: 14)),
                  value: reminders,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => reminders = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark Mode (coming soon)', style: TextStyle(fontSize: 14)),
                  value: darkMode,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => darkMode = v),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _prefRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 22, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      subtitle: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

class _DataSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.file_download_outlined, size: 22, color: AppColors.primary),
              title: const Text('Export Data', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Download your cases as a file', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _toast(context, 'Export data coming soon.'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.backup_outlined, size: 22, color: AppColors.primary),
              title: const Text('Backup & Restore', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Back up your data safely', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _toast(context, 'Backup & restore coming soon.'),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _AccountSection extends ConsumerWidget {
  final BuildContext context;
  final WidgetRef ref;
  final User user;
  const _AccountSection({required this.context, required this.ref, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.help_outline, size: 22, color: AppColors.primary),
              title: const Text('Help & Support', style: TextStyle(fontSize: 14)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _toast('Help & Support coming soon.'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.privacy_tip_outlined, size: 22, color: AppColors.primary),
              title: const Text('Privacy Policy', style: TextStyle(fontSize: 14)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _toast('Privacy Policy coming soon.'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined, size: 22, color: AppColors.primary),
              title: const Text('Terms & Conditions', style: TextStyle(fontSize: 14)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _toast('Terms & Conditions coming soon.'),
            ),
            const Divider(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, size: 22, color: AppColors.danger),
              title: const Text('Logout', style: TextStyle(fontSize: 14, color: AppColors.danger)),
              trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.danger),
              onTap: authState.isLoading ? null : () => _confirmLogout(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_forever_outlined, size: 22, color: AppColors.danger),
              title: const Text('Delete Account', style: TextStyle(fontSize: 14, color: AppColors.danger)),
              subtitle: const Text('Permanently remove your account and data', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.danger),
              onTap: () => _confirmDeleteAccount(),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to access your cases.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
            'This will permanently remove your account and all associated data. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _toast('Account deletion is not yet implemented.');
    }
  }
}

class _ProfilePhotoPicker extends StatefulWidget {
  const _ProfilePhotoPicker();

  @override
  State<_ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<_ProfilePhotoPicker> {
  String? _photoPath;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    setState(() => _photoPath = path);
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _photoPath != null;
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.surfaceAlt,
          backgroundImage: hasPhoto ? FileImage(File(_photoPath!)) : null,
          child: hasPhoto
              ? null
              : const Icon(Icons.add_a_photo_outlined, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: _pick,
          child: Text(hasPhoto ? 'Change photo' : 'Add profile photo'),
        ),
      ],
    );
  }
}

Widget _field(
  TextEditingController controller,
  String label, {
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  int maxLines = 1,
  bool obscure = false,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    obscureText: obscure,
    decoration: InputDecoration(labelText: label, alignLabelWithHint: maxLines > 1),
    validator: validator,
  );
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
