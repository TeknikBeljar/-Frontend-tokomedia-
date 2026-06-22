import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_api_service.dart';

class RegisterWeb extends StatelessWidget {
  const RegisterWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(height: 2, color: const Color(0xFF202735)),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final pageHeight = constraints.maxHeight < 630
                    ? 630.0
                    : constraints.maxHeight;
                final isCompact = constraints.maxWidth < 760;

                return SingleChildScrollView(
                  child: SizedBox(
                    height: pageHeight,
                    child: Stack(
                      children: [
                        const Positioned(
                          top: 14,
                          left: 0,
                          right: 0,
                          child: Center(child: _TokomediaLogo()),
                        ),
                        Positioned(
                          top: isCompact ? 84 : 99,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: isCompact
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: _RegisterCard(),
                                  )
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _RegisterHero(),
                                      SizedBox(width: 84),
                                      _RegisterCard(),
                                    ],
                                  ),
                          ),
                        ),
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 57,
                          child: _RegisterFooter(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TokomediaLogo extends StatelessWidget {
  const _TokomediaLogo();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/home'),
        child: const Text(
          'tokomedia',
          style: TextStyle(
            color: AppColors.green,
            fontSize: 27,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _RegisterHero extends StatelessWidget {
  const _RegisterHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 318,
      child: Column(
        children: [
          Image.asset(
            AppAssets.registerIllustration,
            width: 310,
            height: 255,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 28),
          const Text(
            'Jual Beli Mudah Hanya di Tokomedia',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 11),
          const Text(
            'Gabung dan rasakan kemudahan bertransaksi di Tokomedia',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF5B667A), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

enum _RegisterStep { form, methodSelection, verification }

class _RegisterCard extends StatefulWidget {
  const _RegisterCard();

  @override
  State<_RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<_RegisterCard> {
  final TextEditingController _accountController = TextEditingController();
  bool _canRegister = false;
  _RegisterStep _step = _RegisterStep.form;
  String _confirmedAccount = '';
  String _selectedMethod = '';
  String? _challengeId;
  bool _isLoading = false;
  final AuthApiService _apiService = AuthApiService();

  bool get _isPhone => !_confirmedAccount.contains('@');

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _accountController
      ..removeListener(_updateButtonState)
      ..dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final hasInput = _accountController.text.trim().isNotEmpty;
    if (hasInput != _canRegister) {
      setState(() => _canRegister = hasInput);
    }
  }

  Future<void> _confirmAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (context) {
        return _AccountConfirmationDialog(account: _accountController.text);
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    _confirmedAccount = _accountController.text.trim();

    if (_isPhone) {
      setState(() => _step = _RegisterStep.methodSelection);
    } else {
      setState(() => _isLoading = true);
      final res = await _apiService.requestRegisterOtp(_confirmedAccount, 'email');
      if (mounted) {
        setState(() => _isLoading = false);
        if (res.success && res.challengeId != null) {
          _challengeId = res.challengeId;
          _selectedMethod = 'email';
          setState(() => _step = _RegisterStep.verification);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _RegisterStep.methodSelection) {
      return Stack(
        children: [
          _MethodSelectionCard(
            phoneNumber: _confirmedAccount,
            onBack: () => setState(() => _step = _RegisterStep.form),
            onMethodSelected: (method) async {
              setState(() => _isLoading = true);
              final res = await _apiService.requestRegisterOtp(_confirmedAccount, method);
              if (mounted) {
                setState(() => _isLoading = false);
                if (res.success && res.challengeId != null) {
                  _challengeId = res.challengeId;
                  _selectedMethod = method;
                  setState(() => _step = _RegisterStep.verification);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res.message), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.5),
                child: const Center(child: CircularProgressIndicator(color: AppColors.green)),
              ),
            ),
        ],
      );
    }

    if (_step == _RegisterStep.verification && _challengeId != null) {
      return _VerificationCard(
        account: _confirmedAccount,
        method: _selectedMethod,
        challengeId: _challengeId!,
        isRegister: true,
        onBack: () {
          if (_isPhone) {
            setState(() => _step = _RegisterStep.methodSelection);
          } else {
            setState(() => _step = _RegisterStep.form);
          }
        },
      );
    }

    return Container(
      width: 318,
      padding: const EdgeInsets.fromLTRB(28, 19, 28, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E7EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
            'Daftar Sekarang',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2C3442),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Sudah punya akun Tokomedia? ',
                  style: TextStyle(fontSize: 11, color: Colors.black),
                ),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 38,
            child: OutlinedButton(
              onPressed: () => setState(() => _step = _RegisterStep.verification),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4F5B6F),
                side: const BorderSide(color: Color(0xFFBAC7D8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppAssets.googleIcon,
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'Google',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _DividerLabel(),
          const SizedBox(height: 21),
          _RegisterInput(controller: _accountController),
          const SizedBox(height: 7),
          const Padding(
            padding: EdgeInsets.only(left: 11),
            child: Text(
              'Contoh: email@tokomedia.com',
              style: TextStyle(color: Color(0xFF4F5B6F), fontSize: 9),
            ),
          ),
          const SizedBox(height: 19),
          SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: _canRegister ? _confirmAccount : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE6ECF5),
                disabledForegroundColor: const Color(0xFFA8B5C6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Daftar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Dengan mendaftar, saya menyetujui',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
          const SizedBox(height: 1),
          const Text(
            'Syarat & Ketentuan serta Kebijakan Privasi Tokomedia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.green,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      if (_isLoading)
        Positioned.fill(
          child: Container(
            color: Colors.white.withValues(alpha: 0.5),
            child: const Center(child: CircularProgressIndicator(color: AppColors.green)),
          ),
        ),
      ],
    ),
    );
  }
}

class _AccountConfirmationDialog extends StatelessWidget {
  final String account;

  const _AccountConfirmationDialog({required this.account});

  bool get _isEmail => account.contains('@');

  @override
  Widget build(BuildContext context) {
    final accountType = _isEmail ? 'E-mail' : 'Nomor HP';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.fromLTRB(20, 17, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              account,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'Pastikan $accountType yang kamu\nisi sudah benar untuk diverifikasi.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF2C3442), fontSize: 10),
            ),
            const SizedBox(height: 17),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.green,
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Ubah'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Ya, Benar',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodSelectionCard extends StatelessWidget {
  final String phoneNumber;
  final VoidCallback onBack;
  final ValueChanged<String> onMethodSelected;

  const _MethodSelectionCard({
    required this.phoneNumber,
    required this.onBack,
    required this.onMethodSelected,
  });

  String get _formattedPhone {
    final digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) {
      return '62${digits.substring(1)}';
    }
    if (digits.startsWith('62')) {
      return digits;
    }
    return '62$digits';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 318,
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E7EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 26, height: 26),
              color: const Color(0xFF2C3442),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Pilih Metode Verifikasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2C3442),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pilih salah satu metode dibawah ini untuk\nmendapatkan kode verifikasi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF5B667A), fontSize: 11),
          ),
          const SizedBox(height: 22),
          _MethodOption(
            icon: Icons.chat,
            iconColor: const Color(0xFF25D366),
            label: 'WhatsApp ke',
            value: _formattedPhone,
            onTap: () => onMethodSelected('whatsapp'),
          ),
          const SizedBox(height: 10),
          _MethodOption(
            icon: Icons.sms_outlined,
            iconColor: const Color(0xFF03AC0E),
            label: 'SMS ke',
            value: _formattedPhone,
            onTap: () => onMethodSelected('sms'),
          ),
        ],
      ),
    );
  }
}

class _MethodOption extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _MethodOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  State<_MethodOption> createState() => _MethodOptionState();
}

class _MethodOptionState extends State<_MethodOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFF6F7F9) : Colors.white,
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF03AC0E)
                  : const Color(0xFFE2E7EF),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Color(0xFF2C3442),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.value,
                    style: const TextStyle(
                      color: Color(0xFF5B667A),
                      fontSize: 11,
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

class _VerificationCard extends StatefulWidget {
  final String account;
  final String method;
  final String challengeId;
  final bool isRegister;
  final VoidCallback onBack;

  const _VerificationCard({
    required this.account,
    required this.onBack,
    required this.challengeId,
    required this.isRegister,
    this.method = '',
  });

  @override
  State<_VerificationCard> createState() => _VerificationCardState();
}

class _VerificationCardState extends State<_VerificationCard> {
  final TextEditingController _codeController = TextEditingController();
  final AuthApiService _apiService = AuthApiService();
  bool _isVerifying = false;

  bool get _isEmail => widget.account.contains('@');

  String get _maskedAccount {
    if (_isEmail) {
      final parts = widget.account.split('@');
      final name = parts[0];
      final domain = parts.length > 1 ? parts[1] : '';
      final maskedName = name.isNotEmpty
          ? '${name[0]}${'*' * (name.length - 1)}'
          : '***';
      final domainParts = domain.split('.');
      final maskedDomain = domainParts.isNotEmpty && domainParts[0].isNotEmpty
          ? '${domainParts[0][0]}${'*' * (domainParts[0].length - 1)}'
          : '***';
      final ext = domainParts.length > 1 ? domainParts.sublist(1).join('.') : 'com';
      return '$maskedName@$maskedDomain.$ext';
    } else {
      final digits = widget.account.replaceAll(RegExp(r'[^0-9]'), '');
      String formatted = digits;
      if (digits.startsWith('0')) {
        formatted = '62${digits.substring(1)}';
      } else if (!digits.startsWith('62')) {
        formatted = '62$digits';
      }
      if (formatted.length > 6) {
        return '${formatted.substring(0, 4)}${'*' * (formatted.length - 6)}${formatted.substring(formatted.length - 2)}';
      }
      return formatted;
    }
  }

  String get _verificationMessage {
    if (_isEmail) {
      return 'Kode verifikasi telah dikirim melalui e-mail ke';
    }
    final methodLabel = widget.method == 'whatsapp' ? 'WhatsApp' : 'SMS';
    return 'Kode verifikasi telah dikirim melalui $methodLabel ke';
  }

  void _handleCodeChanged(String value) async {
    final code = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (code.length == 6 && !_isVerifying) {
      setState(() => _isVerifying = true);
      
      final res = widget.isRegister
          ? await _apiService.verifyRegisterOtp(widget.challengeId, code)
          : await _apiService.verifyLoginOtp(widget.challengeId, code);
          
      if (mounted) {
        setState(() => _isVerifying = false);
        if (res.success) {
          context.read<AuthProvider>().login();
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message), backgroundColor: Colors.red),
          );
          _codeController.clear();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 318,
      padding: const EdgeInsets.fromLTRB(31, 24, 31, 35),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E7EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 26, height: 26),
              color: const Color(0xFF2C3442),
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            _isEmail ? Icons.mark_email_unread_outlined : Icons.sms_outlined,
            color: const Color(0xFF39C75A),
            size: 36,
          ),
          const SizedBox(height: 12),
          const Text(
            'Masukkan Kode Verifikasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2C3442),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _verificationMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF2C3442), fontSize: 10),
          ),
          Text(
            '$_maskedAccount.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2C3442),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              _VerificationCodeInput(
                controller: _codeController,
                onChanged: _handleCodeChanged,
                enabled: !_isVerifying,
              ),
              if (_isVerifying)
                const Positioned(
                  right: 0,
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.green),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Mohon tunggu dalam 24 detik untuk kirim ulang',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF2C3442), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _VerificationCodeInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const _VerificationCodeInput({
    required this.controller,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        enabled: enabled,
        autofocus: true,
        textAlign: TextAlign.center,
        cursorColor: Color(0xFF2C3442),
        style: TextStyle(fontSize: 18, letterSpacing: 6),
        decoration: InputDecoration(
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.green),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.green),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.green),
          ),
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFD7DEE8), height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 13),
          child: Text(
            'atau',
            style: TextStyle(color: Color(0xFF5D6A7D), fontSize: 10),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFD7DEE8), height: 1)),
      ],
    );
  }
}

class _RegisterInput extends StatelessWidget {
  final TextEditingController controller;

  const _RegisterInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          labelText: 'Nomor HP atau E-mail',
          labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          floatingLabelStyle: const TextStyle(
            color: AppColors.green,
            fontSize: 12,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 11),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFB9C8DC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.green),
          ),
        ),
      ),
    );
  }
}

class _RegisterFooter extends StatelessWidget {
  const _RegisterFooter();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '\u00A9 2009-2026, PT Tokomedia',
          style: TextStyle(color: Color(0xFF5C667A), fontSize: 12),
        ),
        SizedBox(width: 19),
        Text(
          'Tokomedia Care',
          style: TextStyle(
            color: AppColors.green,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
