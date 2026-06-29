import 'package:contr_project/Presentation/bloc/account_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/login_screen.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../bloc/account_bloc.dart';
import '../../bloc/account_state.dart';
import '../../widgets/error_view.dart';
import '../../bloc/language/language_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../support/support_screen.dart';
import '../../../data/services/biometric_service.dart';
import '../../widgets/shimmer_loading.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/api/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AccountBloc>().add(const FetchAccountBalance(AppConstants.currentAccountId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else if (state is AvatarUploadSuccess) {
          context
              .read<AccountBloc>()
              .add(const FetchAccountBalance(AppConstants.currentAccountId));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture successfully uploaded!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isUploading = authState is AvatarUploadLoading;
          return Stack(
            children: [
              Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                appBar: AppBar(
                  backgroundColor: theme.primaryColor,
                  elevation: 0,
                  title: Text(l10n.profile,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(context),
                      const SizedBox(height: 16),
                      _buildSettingsSections(context),
                      const SizedBox(height: 24),
                      _buildLogoutButton(context),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
              if (isUploading)
                Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const ShimmerLoadingWidget(type: 'summary');
          } else if (state is AccountLoaded) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () => _handleProfilePictureUpdate(context),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: (state.account.avatarUrl != null &&
                                  state.account.avatarUrl!.isNotEmpty)
                              ? NetworkImage(
                                  '${ApiClient.baseUrl.replaceAll('/api', '')}${state.account.avatarUrl}')
                              : null,
                          child: (state.account.avatarUrl == null ||
                                  state.account.avatarUrl!.isEmpty)
                              ? Icon(Icons.person_rounded,
                                  size: 44, color: theme.primaryColor)
                              : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  state.account.accountHolderName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${state.account.id}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            );
          } else if (state is AccountError) {
            return AppErrorView(message: state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSettingsSections(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Appearance
          _buildSectionHeader(l10n.appearance),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _buildThemeSelector(context),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildAccentColorPicker(context),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: Security
          _buildSectionHeader(l10n.security),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: _buildSecurityTile(context),
          ),
          const SizedBox(height: 20),

          // Section: General Settings
          _buildSectionHeader(l10n.settings),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _buildLanguageTile(context),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: const Text('Help & Support'),
                  subtitle: const Text('FAQ, contact, live chat'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SupportScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: About
          _buildSectionHeader(l10n.about),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(l10n.aboutApp),
              subtitle: Text(l10n.appVersion),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Contro Bank',
                  applicationVersion: '1.0.0 (Demo)',
                  applicationLegalese:
                      '© 2026 Contro Bank. All rights reserved.',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 4, right: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = context.watch<ThemeBloc>().state.themeMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined),
              const SizedBox(width: 16),
              Text(l10n.themeMode,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
          DropdownButton<ThemeMode>(
            value: currentTheme,
            onChanged: (ThemeMode? newMode) {
              if (newMode != null) {
                context.read<ThemeBloc>().add(ChangeThemeEvent(newMode));
              }
            },
            underline: const SizedBox.shrink(),
            items: [
              DropdownMenuItem(
                  value: ThemeMode.system, child: Text(l10n.system)),
              DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.light)),
              DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.dark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccentColorPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<ThemeBloc>().state;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.accentColor,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AccentColorType.values.length,
              itemBuilder: (context, index) {
                final type = AccentColorType.values[index];
                final color = type.color;
                final isSelected = state.accentColor == type;

                return GestureDetector(
                  onTap: () {
                    context.read<ThemeBloc>().add(ChangeAccentColorEvent(type));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2)
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.fingerprint_rounded),
      title: Text(l10n.biometrics),
      subtitle: Text(l10n.enableBiometrics),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const _SecurityDialog(),
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLanguage =
        context.watch<LanguageBloc>().state.locale.languageCode;

    return ListTile(
      leading: const Icon(Icons.g_translate_rounded),
      title: Text(l10n.language),
      subtitle: Text(currentLanguage == 'ar' ? 'العربية' : 'English'),
      trailing: const Icon(Icons.swap_horiz_rounded),
      onTap: () {
        final nextLanguage = currentLanguage == 'ar' ? 'en' : 'ar';
        context.read<LanguageBloc>().add(ChangeLanguageEvent(nextLanguage));
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ElevatedButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(LogoutEvent());
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: Text(l10n.logout,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleProfilePictureUpdate(BuildContext context) async {
    if (_isPickingFile) return;
    setState(() {
      _isPickingFile = true;
    });

    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.path != null) {
        if (mounted) {
          context
              .read<AuthBloc>()
              .add(UploadAvatarEvent(result.files.single.path!));
        }
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    }
  }
}

class _SecurityDialog extends StatefulWidget {
  const _SecurityDialog({Key? key}) : super(key: key);

  @override
  __SecurityDialogState createState() => __SecurityDialogState();
}

class __SecurityDialogState extends State<_SecurityDialog> {
  final _biometricService = BiometricService();
  bool _isEnabled = false;
  bool _isAvailable = false;
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    final isAvail = await _biometricService.isBiometricAvailable();
    final isEn = await _biometricService.isBiometricsEnabled();
    if (mounted) {
      setState(() {
        _isAvailable = isAvail;
        _isEnabled = isEn;
        _isLoading = false;
      });
    }
  }

  void _toggleBiometrics(bool value) async {
    if (!value) {
      await _biometricService.disableBiometrics();
      if (mounted) {
        setState(() {
          _isEnabled = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric login disabled successfully')),
      );
    }
  }

  void _enableBiometrics() async {
    if (!_formKey.currentState!.validate()) return;

    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      await _biometricService.saveCredentials(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _isEnabled = true;
        });
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric login enabled successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Biometric authentication failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (!_isAvailable) {
      return AlertDialog(
        title: const Text('Biometric Login'),
        content: const Text(
            'Your device does not support biometric authentication or it is not configured.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Security & Biometrics'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Biometric Login'),
              subtitle:
                  const Text('Log in securely with fingerprint or face ID'),
              value: _isEnabled,
              onChanged: _toggleBiometrics,
              activeThumbColor: theme.primaryColor,
              activeTrackColor: theme.primaryColor.withValues(alpha: 0.5),
            ),
            if (!_isEnabled) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'To enable biometrics, please enter your password. Your credentials will be stored securely on your device.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      decoration: const InputDecoration(
                        labelText: 'Email or Phone',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Field is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Field is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _enableBiometrics,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Enable Biometrics'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
      ],
    );
  }
}
