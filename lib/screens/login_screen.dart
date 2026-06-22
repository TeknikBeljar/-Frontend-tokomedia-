import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../services/auth_api_service.dart';

// MobileAuthSession removed in favor of AuthProvider

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MobileAuthScreen(mode: _MobileAuthMode.login);
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MobileAuthScreen(mode: _MobileAuthMode.register);
  }
}

enum _MobileAuthMode { register, login }

class _MobileAuthScreen extends StatefulWidget {
  final _MobileAuthMode mode;

  const _MobileAuthScreen({required this.mode});

  @override
  State<_MobileAuthScreen> createState() => _MobileAuthScreenState();
}

class _MobileAuthScreenState extends State<_MobileAuthScreen> {
  final TextEditingController _accountController = TextEditingController();
  bool _canSubmit = false;
  bool _showVerificationMethods = false;
  String _confirmedPhone = '';
  String _selectedVerificationMethod = '';
  String? _challengeId;
  bool _isLoading = false;
  final AuthApiService _apiService = AuthApiService();

  bool get _isRegister => widget.mode == _MobileAuthMode.register;

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_updateSubmitState);
  }

  @override
  void dispose() {
    _accountController
      ..removeListener(_updateSubmitState)
      ..dispose();
    super.dispose();
  }

  void _updateSubmitState() {
    final hasInput = _accountController.text.trim().isNotEmpty;
    if (hasInput != _canSubmit) {
      setState(() => _canSubmit = hasInput);
    }
  }

  void _goHome() {
    context.read<AuthProvider>().login();
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _goBack() {
    if (_isRegister) {
      Navigator.maybePop(context);
      return;
    }

    Navigator.pushReplacementNamed(context, '/register');
  }

  void _switchMode() {
    Navigator.pushReplacementNamed(
      context,
      _isRegister ? '/login' : '/register',
    );
  }

  /// Format phone number for display: 08225332-6326 → 0822-5332-6326
  String _formatPhoneDisplay(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length <= 4) return digits;
    if (digits.length <= 8) {
      return '${digits.substring(0, 4)}-${digits.substring(4)}';
    }
    if (digits.length <= 12) {
      return '${digits.substring(0, 4)}-${digits.substring(4, 8)}-${digits.substring(8)}';
    }
    return '${digits.substring(0, 4)}-${digits.substring(4, 8)}-${digits.substring(8, 12)}';
  }

  Future<void> _confirmPhone() async {
    final phone = _accountController.text.trim();
    final isEmail = phone.contains('@');

    if (isEmail) {
      // Email: langsung lanjut tanpa konfirmasi
      _goHome();
      return;
    }

    FocusScope.of(context).unfocus();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (_) =>
          _PhoneConfirmDialog(formattedPhone: _formatPhoneDisplay(phone)),
    );

    if (!mounted || confirmed != true) return;
    setState(() {
      _confirmedPhone = phone;
      _showVerificationMethods = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedVerificationMethod.isNotEmpty && _challengeId != null) {
      return _MobileVerificationCodeScreen(
        title: _isRegister
            ? 'Daftar Sekarang di Tokomedia'
            : 'Masuk ke Tokomedia',
        phoneNumber: _confirmedPhone,
        method: _selectedVerificationMethod,
        challengeId: _challengeId!,
        isRegister: _isRegister,
        onBack: () => setState(() => _selectedVerificationMethod = ''),
        onVerified: _goHome,
      );
    }

    if (_showVerificationMethods) {
      return Stack(
        children: [
          _VerificationMethodScreen(
            phoneNumber: _confirmedPhone,
            onBack: () => setState(() => _showVerificationMethods = false),
            onMethodSelected: (method) async {
              setState(() => _isLoading = true);
              final res = _isRegister
                  ? await _apiService.requestRegisterOtp(_confirmedPhone, method)
                  : await _apiService.requestLoginOtp(_confirmedPhone, method);
              
              if (mounted) {
                setState(() => _isLoading = false);
                if (res.success && res.challengeId != null) {
                  setState(() {
                    _challengeId = res.challengeId;
                    _selectedVerificationMethod = method;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res.message), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator(color: AppColors.green)),
            ),
        ],
      );
    }

    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isShort = constraints.maxHeight < 700;
          final topGap = isShort ? 34.0 : 70.0;
          final bottomPadding = viewInsets.bottom > 0 ? 28.0 : 124.0;

          return Stack(
            children: [
              if (_isRegister)
                const Positioned.fill(
                  child: CustomPaint(painter: _AuthBackdropPainter()),
                ),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.fromLTRB(
                              24,
                              14,
                              24,
                              bottomPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: _goBack,
                                      icon: const Icon(Icons.arrow_back),
                                      iconSize: 34,
                                      color: const Color(0xFF20242A),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 46,
                                        minHeight: 46,
                                      ),
                                    ),
                                    if (!_isRegister)
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.help_outline),
                                        iconSize: 31,
                                        color: const Color(0xFF20242A),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 46,
                                          minHeight: 46,
                                        ),
                                      )
                                    else
                                      const SizedBox(width: 46, height: 46),
                                  ],
                                ),
                                SizedBox(
                                  height: _isRegister
                                      ? topGap
                                      : (isShort ? 48 : 78),
                                ),
                                _AuthHeadline(isRegister: _isRegister),
                                SizedBox(
                                  height: _isRegister
                                      ? (isShort ? 46 : 68)
                                      : (isShort ? 32 : 38),
                                ),
                                _AccountInput(
                                  controller: _accountController,
                                  isRegister: _isRegister,
                                ),
                                const SizedBox(height: 14),
                                _PrimaryAuthButton(
                                  enabled: _canSubmit,
                                  label: _isRegister ? 'Daftar' : 'Lanjut',
                                  onPressed: _confirmPhone,
                                ),
                                SizedBox(height: isShort ? 30 : 42),
                                _AuthDivider(
                                  label: _isRegister
                                      ? 'atau daftar dengan'
                                      : 'atau masuk dengan',
                                ),
                                SizedBox(height: isShort ? 24 : 32),
                                _AuthOptionButton.google(
                                  label: 'Google',
                                  onTap: _goHome,
                                ),
                                const SizedBox(height: 14),
                                _AuthOptionButton.email(
                                  label: 'E-mail',
                                  onTap: _goHome,
                                ),
                                if (!_isRegister) ...[
                                  const SizedBox(height: 14),
                                  _AuthOptionButton.tiktok(
                                    label: 'TikTok Shop',
                                    onTap: _goHome,
                                  ),
                                ],
                                const SizedBox(height: 28),
                                _TermsText(isRegister: _isRegister),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (viewInsets.bottom == 0)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _AuthBottomBar(
                    isRegister: _isRegister,
                    onTap: _switchMode,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AuthHeadline extends StatelessWidget {
  final bool isRegister;

  const _AuthHeadline({required this.isRegister});

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      color: Colors.black,
      fontSize: 23,
      fontWeight: FontWeight.w800,
      height: 1.28,
      letterSpacing: 0,
    );

    if (!isRegister) {
      return const Text(
        'Masuk ke Tokomedia',
        style: TextStyle(
          color: Color(0xFF2B313D),
          fontSize: 25,
          fontWeight: FontWeight.w800,
          height: 1.2,
          letterSpacing: 0,
        ),
      );
    }

    return RichText(
      text: const TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: 'Daftar dan nikmatin '),
          TextSpan(
            text: 'diskon s.d.\nRp30.000',
            style: TextStyle(color: Color(0xFF008E53)),
          ),
          TextSpan(text: ' di belanja pertamamu'),
        ],
      ),
    );
  }
}

class _AccountInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isRegister;

  const _AccountInput({required this.controller, required this.isRegister});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: 'Contoh: 08123456789',
          hintStyle: const TextStyle(
            color: Color(0xFFAAB2C2),
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.phone_android_outlined,
            color: Colors.black,
            size: 29,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 58),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF9EA7B7), width: 1.1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF9EA7B7), width: 1.1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.green, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  const _PrimaryAuthButton({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.green,
          disabledBackgroundColor: const Color(0xFFE8EEF7),
          disabledForegroundColor: const Color(0xFFB3BBC9),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _AuthDivider extends StatelessWidget {
  final String label;

  const _AuthDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE3E7ED), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB2B8C4),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE3E7ED), thickness: 1)),
      ],
    );
  }
}

class _AuthOptionButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const _AuthOptionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  factory _AuthOptionButton.google({
    required String label,
    required VoidCallback onTap,
  }) {
    return _AuthOptionButton(
      label: label,
      onTap: onTap,
      icon: Image.asset(
        AppAssets.googleIcon,
        width: 28,
        height: 28,
        fit: BoxFit.contain,
      ),
    );
  }

  factory _AuthOptionButton.email({
    required String label,
    required VoidCallback onTap,
  }) {
    return _AuthOptionButton(
      label: label,
      onTap: onTap,
      icon: const Icon(Icons.mail_outline, color: Colors.black, size: 30),
    );
  }

  factory _AuthOptionButton.tiktok({
    required String label,
    required VoidCallback onTap,
  }) {
    return _AuthOptionButton(
      label: label,
      onTap: onTap,
      icon: Image.asset(
        AppAssets.tiktokIcon,
        width: 28,
        height: 28,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDE3EB), width: 1.3),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(left: 34, child: icon),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF555B66),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsText extends StatelessWidget {
  final bool isRegister;

  const _TermsText({required this.isRegister});

  @override
  Widget build(BuildContext context) {
    final prefix = isRegister
        ? 'Dengan mendaftar di sini, kamu menyetujui '
        : 'Dengan masuk di sini, kamu menyetujui ';

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF4C5360),
          fontSize: 15,
          height: 1.4,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        children: [
          TextSpan(text: prefix),
          const TextSpan(
            text: 'Syarat & Ketentuan',
            style: TextStyle(
              color: Color(0xFF008E53),
              fontWeight: FontWeight.w800,
            ),
          ),
          const TextSpan(text: ' serta '),
          const TextSpan(
            text: 'Kebijakan Privasi',
            style: TextStyle(
              color: Color(0xFF008E53),
              fontWeight: FontWeight.w800,
            ),
          ),
          const TextSpan(text: ' Tokomedia.'),
        ],
      ),
    );
  }
}

class _AuthBottomBar extends StatelessWidget {
  final bool isRegister;
  final VoidCallback onTap;

  const _AuthBottomBar({required this.isRegister, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF1F4F8),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  isRegister ? 'Sudah punya akun? ' : 'Belum punya akun? ',
                  style: const TextStyle(
                    color: Color(0xFF2D3440),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    isRegister ? 'Masuk' : 'Daftar Sekarang',
                    style: const TextStyle(
                      color: Color(0xFF008E53),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBackdropPainter extends CustomPainter {
  const _AuthBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFFF9FAFC)
      ..style = PaintingStyle.fill;
    final line = Paint()
      ..color = const Color(0xFFE5EAF1).withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(Offset(size.width * 0.06, size.height * 0.18), 182, fill);
    canvas.drawCircle(Offset(size.width * 0.96, size.height * 0.18), 186, fill);
    canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.07), 200, line);
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.19), 150, line);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.04), 270, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// PHONE CONFIRMATION SHEET (modal bottom sheet)
// ─────────────────────────────────────────────
class _MobileVerificationCodeScreen extends StatefulWidget {
  final String title;
  final String phoneNumber;
  final String method;
  final String challengeId;
  final bool isRegister;
  final VoidCallback onBack;
  final VoidCallback onVerified;

  const _MobileVerificationCodeScreen({
    required this.title,
    required this.phoneNumber,
    required this.method,
    required this.challengeId,
    required this.isRegister,
    required this.onBack,
    required this.onVerified,
  });

  @override
  State<_MobileVerificationCodeScreen> createState() =>
      _MobileVerificationCodeScreenState();
}

class _MobileVerificationCodeScreenState
    extends State<_MobileVerificationCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final AuthApiService _apiService = AuthApiService();
  Timer? _timer;
  int _remainingSeconds = 24;
  bool _isVerifying = false;

  bool get _isWhatsApp => widget.method == 'whatsapp';

  String get _internationalPhone {
    final digits = widget.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) {
      return '62${digits.substring(1)}';
    }
    if (digits.startsWith('62')) {
      return digits;
    }
    return '62$digits';
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() => _remainingSeconds = 0);
        }
        return;
      }
      if (mounted) {
        setState(() => _remainingSeconds--);
      }
    });
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
          widget.onVerified();
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
    final methodLabel = _isWhatsApp ? 'WhatsApp' : 'SMS';

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final iconGap = (constraints.maxHeight * 0.11).clamp(62.0, 105.0);

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 52,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: widget.onBack,
                                icon: const Icon(Icons.arrow_back),
                                iconSize: 34,
                                color: const Color(0xFF6D7588),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 46,
                                  minHeight: 46,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 58),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Color(0xFF202124),
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: iconGap),
                      Center(
                        child: _isWhatsApp
                            ? const _WhatsAppMethodIcon()
                            : const Icon(
                                Icons.chat_outlined,
                                color: Color(0xFF31D158),
                                size: 54,
                              ),
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'Masukkan Kode Verifikasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF363A43),
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Kode verifikasi telah dikirim melalui $methodLabel ke\n$_internationalPhone.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF7A7F87),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 230,
                              height: 48,
                              child: TextField(
                                controller: _codeController,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                maxLength: 6,
                                textAlign: TextAlign.center,
                                cursorColor: AppColors.green,
                                onChanged: _handleCodeChanged,
                                enabled: !_isVerifying,
                                style: const TextStyle(
                                  color: Color(0xFF202124),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 10,
                                ),
                                decoration: const InputDecoration(
                                  counterText: '',
                                  contentPadding: EdgeInsets.zero,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.green,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.green,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_isVerifying)
                              const Positioned(
                                right: -40,
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.green),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 38),
                      Text(
                        _remainingSeconds > 0
                            ? 'Mohon tunggu dalam $_remainingSeconds detik untuk kirim ulang.'
                            : 'Kirim ulang kode verifikasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _remainingSeconds > 0
                              ? const Color(0xFF7A7F87)
                              : AppColors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VerificationMethodScreen extends StatelessWidget {
  final String phoneNumber;
  final VoidCallback onBack;
  final ValueChanged<String> onMethodSelected;

  const _VerificationMethodScreen({
    required this.phoneNumber,
    required this.onBack,
    required this.onMethodSelected,
  });

  String get _internationalPhone {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final titleGap = (constraints.maxHeight * 0.25 - 60).clamp(
              72.0,
              145.0,
            );

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back),
                          iconSize: 34,
                          color: const Color(0xFF6D7588),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 46,
                            minHeight: 46,
                          ),
                        ),
                      ),
                      SizedBox(height: titleGap),
                      const Text(
                        'Pilih Metode Verifikasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF202124),
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Pilih salah satu metode dibawah ini untuk\nmendapatkan kode verifikasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF747474),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Column(
                          children: [
                            _VerificationMethodCard(
                              icon: const _WhatsAppMethodIcon(),
                              title: 'WhatsApp ke',
                              phoneNumber: _internationalPhone,
                              onTap: () => onMethodSelected('whatsapp'),
                            ),
                            const SizedBox(height: 18),
                            _VerificationMethodCard(
                              icon: const Icon(
                                Icons.chat_outlined,
                                color: Color(0xFF31D158),
                                size: 50,
                              ),
                              title: 'SMS ke',
                              phoneNumber: _internationalPhone,
                              onTap: () => onMethodSelected('sms'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VerificationMethodCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String phoneNumber;
  final VoidCallback onTap;

  const _VerificationMethodCard({
    required this.icon,
    required this.title,
    required this.phoneNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      shadowColor: const Color(0xFFBFC5CE).withValues(alpha: 0.34),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 104,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                SizedBox(width: 58, child: Center(child: icon)),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF202124),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phoneNumber,
                        style: const TextStyle(
                          color: Color(0xFF747474),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WhatsAppMethodIcon extends StatelessWidget {
  const _WhatsAppMethodIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, color: Color(0xFF31D158), size: 54),
          Icon(Icons.phone, color: Color(0xFF31D158), size: 25),
        ],
      ),
    );
  }
}

class _PhoneConfirmDialog extends StatelessWidget {
  final String formattedPhone;

  const _PhoneConfirmDialog({required this.formattedPhone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 27, 24, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formattedPhone,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2C3442),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.18,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Apakah nomor ponsel yang Anda masukkan\nsudah benar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6D7588),
                  fontSize: 15,
                  height: 1.28,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 31),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6D7588),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                        child: const Text('Ubah'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Ya, Benar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
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
      ),
    );
  }
}

// ignore: unused_element
class _LegacyPhoneConfirmDialog extends StatelessWidget {
  final String formattedPhone;

  const _LegacyPhoneConfirmDialog({required this.formattedPhone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // dimmed tappable area at top — tap to dismiss
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(context, false),
            child: const SizedBox(height: 0),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Phone number bold
                Text(
                  formattedPhone,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Apakah nomor ponsel yang Anda masukkan\nsudah benar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    // Ubah button
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6B7280),
                            textStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Ubah'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Ya, Benar button
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF008E53),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Ya, Benar',
                            style: TextStyle(
                              fontSize: 17,
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
        ],
      ),
    );
  }
}
