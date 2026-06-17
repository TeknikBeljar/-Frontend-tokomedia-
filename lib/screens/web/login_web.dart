import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../../services/auth_api_service.dart';

class LoginWeb extends StatelessWidget {
  const LoginWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final pageHeight = constraints.maxHeight < 632
              ? 632.0
              : constraints.maxHeight;
          final isCompact = constraints.maxWidth < 700;

          return SingleChildScrollView(
            child: SizedBox(
              height: pageHeight,
              child: Stack(
                children: [
                  if (!isCompact)
                    Positioned(
                      top: 84,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Center(
                          child: Image.asset(
                            AppAssets.loginBackground,
                            width: 610,
                            height: 438,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  const Positioned(
                    top: 27,
                    left: 0,
                    right: 0,
                    child: Center(child: _TokomediaLogo()),
                  ),
                  Positioned(
                    top: isCompact ? 94 : 94,
                    left: 0,
                    right: 0,
                    child: const Center(child: _LoginCard()),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 3,
                    child: _LoginFooter(),
                  ),
                ],
              ),
            ),
          );
        },
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
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }
}

enum _LoginStep { form, methodSelection, verification }

class _LoginCard extends StatefulWidget {
  const _LoginCard();

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  final TextEditingController _accountController = TextEditingController();
  bool _canContinue = false;
  _LoginStep _step = _LoginStep.form;
  String _confirmedAccount = '';
  String _selectedMethod = '';
  String? _challengeId;
  bool _isLoading = false;
  final AuthApiService _apiService = AuthApiService();

  bool get _isEmail => _confirmedAccount.contains('@');

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
    if (hasInput != _canContinue) {
      setState(() => _canContinue = hasInput);
    }
  }

  Future<void> _proceedLogin() async {
    _confirmedAccount = _accountController.text.trim();
    
    if (_isEmail) {
      setState(() => _isLoading = true);
      final res = await _apiService.requestLoginOtp(_confirmedAccount, 'email');
      if (mounted) {
        setState(() => _isLoading = false);
        if (res.success && res.challengeId != null) {
          _challengeId = res.challengeId;
          _selectedMethod = 'email';
          setState(() => _step = _LoginStep.verification);
        } else {
          final confirmed = await showDialog<bool>(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.58),
            builder: (context) {
              return _UnregisteredAccountDialog(account: _confirmedAccount);
            },
          );
          if (confirmed == true && mounted) {
            Navigator.pushReplacementNamed(context, '/register');
          }
        }
      }
    } else {
      setState(() => _step = _LoginStep.methodSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _LoginStep.verification && _challengeId != null) {
      return _LoginVerificationCard(
        account: _confirmedAccount,
        method: _selectedMethod,
        challengeId: _challengeId!,
        isRegister: false,
        onBack: () {
          if (_isEmail) {
            setState(() => _step = _LoginStep.form);
          } else {
            setState(() => _step = _LoginStep.methodSelection);
          }
        },
      );
    }

    if (_step == _LoginStep.methodSelection) {
      return Stack(
        children: [
          _VerificationMethodCard(
            account: _confirmedAccount,
            onBack: () => setState(() => _step = _LoginStep.form),
            onMethodSelected: (method) async {
              setState(() => _isLoading = true);
              final res = await _apiService.requestLoginOtp(_confirmedAccount, method);
              if (mounted) {
                setState(() => _isLoading = false);
                if (res.success && res.challengeId != null) {
                  _challengeId = res.challengeId;
                  _selectedMethod = method;
                  setState(() => _step = _LoginStep.verification);
                } else {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    barrierColor: Colors.black.withValues(alpha: 0.58),
                    builder: (context) {
                      return _UnregisteredAccountDialog(account: _confirmedAccount);
                    },
                  );
                  if (confirmed == true && mounted) {
                    Navigator.pushReplacementNamed(context, '/register');
                  }
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

    return Stack(
      children: [
        Container(
      width: 296,
      padding: const EdgeInsets.fromLTRB(26, 52, 26, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E7EF)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 9,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Masuk ke Tokomedia',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              InkWell(
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/register'),
                child: const Text(
                  'Daftar',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          _LoginInput(controller: _accountController),
          const SizedBox(height: 3),
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Contoh: 08123456789',
              style: TextStyle(color: Color(0xFF4F5B6F), fontSize: 8),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Butuh bantuan?',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: _canContinue ? _proceedLogin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE5EBF4),
                disabledForegroundColor: const Color(0xFFA5B1C3),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Selanjutnya',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _DividerLabel(),
          const SizedBox(height: 26),
          const _LoginOptionButton(
            icon: Icons.qr_code_scanner,
            label: 'Scan Kode QR',
          ),
          const SizedBox(height: 7),
          _LoginOptionButton(
            google: true,
            label: 'Google',
            onPressed: () {
              _confirmedAccount = 'user@gmail.com';
              setState(() => _step = _LoginStep.verification);
            },
          ),
          const SizedBox(height: 7),
          const _LoginOptionButton(tiktok: true, label: 'Masuk dengan TikTok'),
        ],
      ),
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
}

class _UnregisteredAccountDialog extends StatelessWidget {
  final String account;

  const _UnregisteredAccountDialog({required this.account});

  bool get _isEmail => account.contains('@');

  @override
  Widget build(BuildContext context) {
    final normalizedAccount = account.trim();
    final accountType = _isEmail ? 'E-mail' : 'Nomor HP';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.fromLTRB(22, 18, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$accountType belum terdaftar',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF212121),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Lanjut daftar dengan ${accountType.toLowerCase()} ini',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
            Text(
              normalizedAccount,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
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
                        'Ya, Daftar',
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

class _VerificationMethodCard extends StatelessWidget {
  final String account;
  final VoidCallback onBack;
  final ValueChanged<String> onMethodSelected;

  const _VerificationMethodCard({
    required this.account,
    required this.onBack,
    required this.onMethodSelected,
  });

  String get _formattedPhone {
    final digits = account.replaceAll(RegExp(r'[^0-9]'), '');
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
      width: 296,
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E7EF)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 9,
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
          const SizedBox(height: 24),
          const Text(
            'Pilih Metode Verifikasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2C3442),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Pilih salah satu metode dibawah ini untuk\nmendapatkan kode verifikasi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF2C3442), fontSize: 10),
          ),
          const SizedBox(height: 20),
          _VerificationMethodOption(
            icon: Icons.chat_bubble_outline,
            title: 'WhatsApp ke',
            subtitle: _formattedPhone,
            onTap: () => onMethodSelected('whatsapp'),
          ),
          const SizedBox(height: 12),
          _VerificationMethodOption(
            icon: Icons.message_outlined,
            title: 'SMS ke',
            subtitle: _formattedPhone,
            onTap: () => onMethodSelected('sms'),
          ),
        ],
      ),
    );
  }
}

class _VerificationMethodOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _VerificationMethodOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          foregroundColor: const Color(0xFF2C3442),
          side: const BorderSide(color: Color(0xFFE2E7EF)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shadowColor: Colors.black.withValues(alpha: 0.18),
          elevation: 2,
          backgroundColor: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF21C465), size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF2C3442),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF2C3442),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginVerificationCard extends StatefulWidget {
  final String account;
  final String method;
  final String challengeId;
  final bool isRegister;
  final VoidCallback onBack;

  const _LoginVerificationCard({
    required this.account,
    required this.onBack,
    required this.challengeId,
    required this.isRegister,
    this.method = '',
  });

  @override
  State<_LoginVerificationCard> createState() => _LoginVerificationCardState();
}

class _LoginVerificationCardState extends State<_LoginVerificationCard> {
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
      width: 296,
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E7EF)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 9,
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
          const SizedBox(height: 14),
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
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              _LoginVerificationCodeInput(
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
          const SizedBox(height: 15),
          const Text(
            'Mohon tunggu dalam 27 detik untuk kirim ulang',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF2C3442), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _LoginVerificationCodeInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const _LoginVerificationCodeInput({
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

class _LoginInput extends StatelessWidget {
  final TextEditingController controller;

  const _LoginInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 39,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          labelText: 'Nomor HP atau Email',
          labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          floatingLabelStyle: const TextStyle(
            color: AppColors.green,
            fontSize: 12,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFB8C6DA)),
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
            'atau masuk dengan',
            style: TextStyle(color: Color(0xFF5D6A7D), fontSize: 10),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFD7DEE8), height: 1)),
      ],
    );
  }
}

class _LoginOptionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool google;
  final bool tiktok;
  final VoidCallback? onPressed;

  const _LoginOptionButton({
    required this.label,
    this.icon,
    this.google = false,
    this.tiktok = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 37,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4F5B6F),
          side: const BorderSide(color: Color(0xFFBAC7D8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (google)
              Image.asset(
                AppAssets.googleIcon,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              )
            else if (tiktok)
              Image.asset(
                AppAssets.tiktokIcon,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              )
            else
              Icon(icon, size: 16, color: const Color(0xFF667085)),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '\u00A9 2009-2026, PT Tokomedia',
          style: TextStyle(color: Colors.black, fontSize: 11),
        ),
        SizedBox(width: 12),
        Text('|', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 11)),
        SizedBox(width: 12),
        Text(
          'Bantuan',
          style: TextStyle(
            color: AppColors.green,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
