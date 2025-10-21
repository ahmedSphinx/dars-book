import 'package:dars_book/features/security/presentation/bloc/app_lock_bloc.dart'
    as app_lock;
import 'package:dars_book/features/settings/presentation/bloc/settings_bloc.dart'
    as settings;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات'),
      ),
      body: ListView(
        children: [
          // Theme Section
          _SectionHeader('المظهر'),
          BlocBuilder<settings.SettingsBloc, settings.SettingsState>(
            builder: (context, state) {
              return ListTile(
                leading: Icon(
                  state.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : state.themeMode == ThemeMode.light
                          ? Icons.light_mode
                          : Icons.brightness_auto,
                ),
                title: const Text('المظهر'),
                subtitle: Text(_getThemeModeLabel(state.themeMode)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showThemeDialog(context, state.themeMode),
              );
            },
          ),

          // Language Section
          /*  ListTile(
            leading: const Icon(Icons.language),
            title: Text('settings.language'),
            subtitle: Text(context.locale.languageCode == 'ar' ? 'العربية' : 'English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(context, context.locale),
          ),
          
          const Divider(),
           */
          // Security Section
          _SectionHeader('الأمان'),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text('قفل التطبيق'),
            subtitle: const Text('قفل التطبيق برمز PIN'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _enableAppLock(context),
          ),
          BlocBuilder<app_lock.AppLockBloc, app_lock.AppLockState>(
            builder: (context, state) {
              bool isBiometricAvailable = false;
              if (state is app_lock.BiometricAvailable) {
                isBiometricAvailable = state.available;
              }
              return SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const Text('فتح بالبصمة'),
                subtitle: const Text('استخدام البصمة لفتح التطبيق'),
                value: (isBiometricAvailable && _isBiometricEnabled(context)),
                onChanged: isBiometricAvailable ? (value) => _toggleBiometric(context, value) : null,
              );
            },
          ),

          const Divider(),

          // Data Section
          _SectionHeader('البيانات'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('نسخ احتياطي'),
            subtitle: const Text('حفظ نسخة من بياناتك'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement backup
              EasyLoading.showToast('قريبًا...');
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('استعادة البيانات'),
            subtitle: const Text('استعادة نسخة احتياطية'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement restore
              EasyLoading.showToast('قريبًا...');
            },
          ),

          const Divider(),

          // About Section
          _SectionHeader('حول التطبيق'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('الإصدار'),
            subtitle: const Text('1.0.0 (1)'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('سياسة الخصوصية'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('الشروط والأحكام'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show terms
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'تلقائي (حسب النظام)';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('المظهر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('فاتح'),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<settings.SettingsBloc>().add(settings.SetThemeModeEvent(value));
                  Navigator.pop(dialogContext);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('داكن'),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<settings.SettingsBloc>().add(settings.SetThemeModeEvent(value));
                  Navigator.pop(dialogContext);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('تلقائي (حسب النظام)'),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<settings.SettingsBloc>().add(settings.SetThemeModeEvent(value));
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

/* 
  void _showLanguageDialog(BuildContext context, Locale currentLocale) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('settings.language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  context.read<LocaleCubit>().changeLocale(Locale(value));
                  context.setLocale(Locale(value));
                  Navigator.pop(dialogContext);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  context.read<LocaleCubit>().changeLocale(Locale(value));
                  context.setLocale(Locale(value));
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

 */
  void _enableAppLock(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SetupPinScreen(false),
      ),
    );
  }

  bool _isBiometricEnabled(BuildContext context) {
    return context.read<settings.SettingsBloc>().state.biometricEnabled;
  }

  void _toggleBiometric(BuildContext context, bool enabled) {
    context.read<settings.SettingsBloc>().add(settings.SetBiometricEnabledEvent(enabled));
    EasyLoading.showToast(enabled ? 'تم تفعيل فتح بالبصمة' : 'تم إلغاء تفعيل فتح بالبصمة');
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _SetupPinScreen extends StatefulWidget {
  final bool isChanging;

  const _SetupPinScreen(this.isChanging);

  @override
  State<_SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<_SetupPinScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isChanging ? 'تغيير رمز القفل' : 'إعداد رمز القفل'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              _isConfirming ? 'أعد إدخال الرمز' : 'أدخل رمز القفل',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),

            // Pin Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final currentPin = _isConfirming ? _confirmPin : _pin;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < currentPin.length
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),

            // Number Pad
            _buildNumberPad(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 80), // Empty space
              _buildNumberButton('0'),
              _buildDeleteButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _onNumberTap(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: _onDelete,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Icon(Icons.backspace_outlined),
        ),
      ),
    );
  }

  void _onNumberTap(String number) {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.length < 4) {
          _confirmPin += number;
          if (_confirmPin.length == 4) {
            _validatePin();
          }
        }
      } else {
        if (_pin.length < 4) {
          _pin += number;
          if (_pin.length == 4) {
            _isConfirming = true;
          }
        }
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  void _validatePin() {
    if (_pin == _confirmPin) {
      context.read<app_lock.AppLockBloc>().add(app_lock.SetPinEvent(_pin));
      Navigator.pop(context);
      EasyLoading.showSuccess('تم تفعيل قفل التطبيق بنجاح');
    } else {
      EasyLoading.showError('الرمز غير متطابق، حاول مرة أخرى');
      setState(() {
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
    }
  }
}
