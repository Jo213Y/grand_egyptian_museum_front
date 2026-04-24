import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/button.dart';
import '../widgets/common_widgets.dart';
import '../services/api_service.dart';
import '../utils/app_assets.dart';
import '../widgets/input_field.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;

    return Scaffold(
      body: GemBackground(
        imageAsset: AppAssets.bgSignIn,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 0 : 20, vertical: 32),
              child: Column(children: [
                // ── Logo ──────────────────────────────────────
                Image.asset(AppAssets.logoGold, width: 90, height: 90,
                    errorBuilder: (_, __, ___) => Image.network(AppAssets.logoGoldUrl,
                        width: 90, height: 90,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.museum, size: 90, color: AppColors.gold))),
                const SizedBox(height: 6),
                const Text('Grand Egyptian Museum',
                    style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w400)),
                const SizedBox(height: 32),

                // ── Form card ─────────────────────────────────
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 552),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppColors.primaryLight),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Title
                        const Text('Welcome Back',
                            style: TextStyle(color: Colors.white, fontSize: 36,
                                fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                        const SizedBox(height: 28),

                        // Email
                        GemTextField(
                          label: 'Email Address',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v != null && v.contains('@') ? null : 'Enter valid email',
                        ),
                        const SizedBox(height: 16),

                        // Password
                        GemTextField(
                          label: 'Password',
                          controller: _passCtrl,
                          obscure: true,
                          validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                        ),

                        // Error
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                        ],
                        const SizedBox(height: 24),

                        // Sign in button
                        GemButton(label: 'Sign in', onPressed: _login, loading: _loading),
                        const SizedBox(height: 16),

                        // Register link
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Text("Don't have an account?  ",
                              style: TextStyle(color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white, fontSize: 14)),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen())),
                            child: const Text('Register',
                                style: TextStyle(color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary, fontSize: 14)),
                          ),
                        ]),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
