import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../navigation/main_screen.dart';

class OtpAuthScreen extends StatefulWidget {
  final bool isProfileConfigMode;

  const OtpAuthScreen({super.key, this.isProfileConfigMode = false});

  @override
  State<OtpAuthScreen> createState() => _OtpAuthScreenState();
}

class _OtpAuthScreenState extends State<OtpAuthScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '912345678');
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String _selectedCountryCode = '+1';
  bool _codeSent = false;
  bool _isVerifying = false;
  int _countdown = 60;
  Timer? _timer;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'country': 'USA / Canada 🇺🇸'},
    {'code': '+251', 'country': 'Ethiopia 🇪🇹'},
    {'code': '+44', 'country': 'UK 🇬🇧'},
    {'code': '+91', 'country': 'India 🇮🇳'},
    {'code': '+49', 'country': 'Germany 🇩🇪'},
    {'code': '+971', 'country': 'UAE 🇦🇪'},
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        t.cancel();
      }
    });
  }

  void _sendOtp() {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid mobile phone number')),
      );
      return;
    }

    setState(() => _codeSent = true);
    _startCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.sms_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '💬 SMS OTP Sent to $_selectedCountryCode ${_phoneController.text}. Demo Code: 123456',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryLight,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _autoFillDemoCode() {
    const demoCode = '123456';
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = demoCode[i];
    }
    _verifyOtp();
  }

  void _verifyOtp() async {
    final enteredCode = _otpControllers.map((c) => c.text).join();
    if (enteredCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits of the OTP code')),
      );
      return;
    }

    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _isVerifying = false);

    final fullPhone = '$_selectedCountryCode ${_phoneController.text.trim()}';

    final userProvider = context.read<UserProvider>();
    await userProvider.updatePhone(fullPhone);
    await userProvider.setPhoneVerified(true);

    if (widget.isProfileConfigMode) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Phone number verified and mobile OTP configured successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      await userProvider.setLoggedIn(true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkEmeraldBg = Color(0xFF091E17);

    return Scaffold(
      backgroundColor: darkEmeraldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isProfileConfigMode ? 'OTP Security Config' : 'Mobile OTP Verification',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Emblem
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Icon(
                    Icons.phonelink_ring_rounded,
                    size: 54,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  _codeSent ? 'Enter 6-Digit OTP Code' : 'Mobile Phone Verification',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _codeSent
                      ? 'We sent a verification SMS code to $_selectedCountryCode ${_phoneController.text}'
                      : 'Enter your mobile number to receive a secure 6-digit verification code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 32),

                if (!_codeSent) ...[
                  // Country Code & Phone Input Row
                  Row(
                    children: [
                      // Country Code Dropdown Container
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            dropdownColor: const Color(0xFF0F3528),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            items: _countryCodes.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['code'],
                                child: Text('${item['code']} ${item['country']}'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCountryCode = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Phone Input
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: 'Mobile number',
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _sendOtp,
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      label: const Text(
                        'Send OTP Code via SMS',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                      ),
                    ),
                  ),
                ] else ...[
                  // 6 OTP Digit Input Boxes Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 46,
                        height: 58,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.1),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (val.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            if (index == 5 && val.isNotEmpty) {
                              _verifyOtp();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Auto-Fill Demo Code Assistant Button
                  TextButton.icon(
                    onPressed: _autoFillDemoCode,
                    icon: const Icon(Icons.auto_fix_high_rounded, color: AppColors.primaryLight),
                    label: const Text(
                      '✨ Tap to Auto-Fill Demo Code (123456)',
                      style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Verify Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                      ),
                      child: _isVerifying
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Verify & Proceed',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _countdown > 0 ? 'Resend code in ${_countdown}s' : "Didn't receive code? ",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      ),
                      if (_countdown == 0)
                        GestureDetector(
                          onTap: _sendOtp,
                          child: const Text(
                            'Resend SMS',
                            style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
