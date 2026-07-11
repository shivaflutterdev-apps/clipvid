import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../blocs/theme_bloc/theme_bloc.dart';
import '../blocs/theme_bloc/theme_event.dart';
import '../blocs/theme_bloc/theme_state.dart';
import 'auth_gate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: context.colors.bgDark,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.inter(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            if (user != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: context.colors.primary,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name.isNotEmpty ? user.name : 'User',
                            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(user.email,
                            style: GoogleFonts.inter(fontSize: 14, color: context.colors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.colors.accent.withOpacity(0.3)),
                    ),
                    child: Text(user.plan, style: GoogleFonts.inter(color: context.colors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],

            Text('PREFERENCES', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.textMuted, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildListTile(
              icon: Icons.dark_mode,
              title: 'Dark Theme',
              trailing: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return Switch(
                    value: state.isDark,
                    activeColor: state.colors.primary,
                    inactiveThumbColor: state.colors.textMuted,
                    inactiveTrackColor: state.colors.border,
                    onChanged: (val) {
                      context.read<ThemeBloc>().add(ThemeToggleEvent());
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
            Text('ACCOUNT', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.textMuted, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildListTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () => _showChangePasswordDialog(context),
            ),
            const SizedBox(height: 12),
            _buildListTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: 12),
            _buildListTile(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              titleColor: context.colors.error,
              iconColor: context.colors.error,
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Color? titleColor,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? context.colors.textSecondary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: titleColor ?? context.colors.textPrimary)),
            ),
            if (trailing != null) trailing else Icon(Icons.chevron_right, color: context.colors.textMuted, size: 24),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgSurface,
        title: Text('Logout', style: GoogleFonts.inter(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to log out?', style: GoogleFonts.inter(color: context.colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthGate()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: context.colors.bgSurface,
            title: Text('Change Password', style: GoogleFonts.inter(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPwdCtrl,
                  obscureText: true,
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: TextStyle(color: context.colors.textSecondary),
                    filled: true,
                    fillColor: context.colors.bgDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPwdCtrl,
                  obscureText: true,
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: context.colors.textSecondary),
                    filled: true,
                    fillColor: context.colors.bgDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(ctx).pop(),
                child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setDialogState(() => isLoading = true);
                  try {
                    await context.read<AuthProvider>().changePassword(currentPwdCtrl.text, newPwdCtrl.text);
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully')));
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  } finally {
                    if (ctx.mounted) setDialogState(() => isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                child: isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: context.colors.bgSurface,
            title: Text('Delete Account', style: GoogleFonts.inter(color: context.colors.error, fontWeight: FontWeight.bold)),
            content: Text('Are you sure you want to permanently delete your account? This action cannot be undone and all your clips will be lost.', 
              style: GoogleFonts.inter(color: context.colors.textSecondary)),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(ctx).pop(),
                child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setDialogState(() => isLoading = true);
                  try {
                    await context.read<AuthProvider>().deleteAccount();
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthGate()),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  } finally {
                    if (ctx.mounted) setDialogState(() => isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: context.colors.error),
                child: isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }
}
