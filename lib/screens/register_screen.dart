import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/widgets/dropdown_field.dart';
import '../theme/app_theme.dart';
import '../widgets/button.dart';
import '../widgets/common_widgets.dart';
import '../services/api_service.dart';
import '../utils/app_assets.dart';
import '../widgets/input_field.dart';
import 'signin_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _nationalIdCtrl = TextEditingController();
  final _passportCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  String? _selectedCountry;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiService.register(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        phone: _phoneCtrl.text.trim(),
        country: _selectedCountry,
        nationalId: _selectedCountry == 'Egypt' ? _nationalIdCtrl.text : null,
        passportNumber:
        _selectedCountry != 'Egypt' ? _passportCtrl.text : null,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GemBackground(
        imageAsset: AppAssets.bgSignIn,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                children: [
                  Image.asset(
                    AppAssets.logoGold,
                    width: 90,
                    height: 90,
                  ),
                  const SizedBox(height: 32),

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 552),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(25),
                        border:
                        Border.all(color: AppColors.primaryLight),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 28),

                            GemTextField(
                              label: 'Full Name',
                              controller: _nameCtrl,
                              validator: (v) =>
                              v!.isEmpty ? 'Required' : null,
                            ),

                            const SizedBox(height: 14),

                            GemTextField(
                              label: 'Email Address',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                              v!.contains('@') ? null : 'Invalid email',
                            ),

                            const SizedBox(height: 14),

                            GemTextField(
                              label: 'Phone Number',
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Phone number is required';
                                }

                                String clean =
                                value.replaceAll(RegExp(r'[^\d]'), '');

                                if (!RegExp(r'^01[0-2,5,6,7,8,9]\d{8}$')
                                    .hasMatch(clean)) {
                                  return 'Invalid phone number';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            // Country
                            GemDropdownField<String>(
                              label: 'Country',
                              value: _selectedCountry,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Egypt',
                                  child: Text('Egypt'),
                                ),
                                DropdownMenuItem(
                                  value: 'Other',
                                  child: Text('Other'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCountry = value;
                                  _nationalIdCtrl.clear();
                                  _passportCtrl.clear();
                                });
                              },
                              validator: (v) =>
                              v == null ? 'Select country' : null,
                            ),

                            const SizedBox(height: 14),

                            if (_selectedCountry == 'Egypt') ...[
                              GemTextField(
                                label: 'National ID',
                                controller: _nationalIdCtrl,
                                keyboardType: TextInputType.text,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Required';
                                  }

                                  // 👇 يتأكد إن كله أرقام بس
                                  if (!RegExp(r'^\d+$').hasMatch(v)) {
                                    return 'Invalid ID';
                                  }

                                  if (v.length != 14) {
                                    return 'Must be 14 digits';
                                  }

                                  return null;
                                },
                              ),
                            ] else if (_selectedCountry != null) ...[
                              GemTextField(
                                label: 'Passport Number',
                                controller: _passportCtrl,
                                validator: (v) =>
                                v!.isEmpty ? 'Required' : null,
                              ),
                            ],

                            const SizedBox(height: 14),

                            GemTextField(
                              label: 'Password',
                              controller: _passCtrl,
                              obscure: true,
                              validator: (v) => v!.length >= 6
                                  ? null
                                  : 'Min 6 chars',
                            ),

                            const SizedBox(height: 14),

                            GemTextField(
                              label: 'Confirm Password',
                              controller: _confirmCtrl,
                              obscure: true,
                              validator: (v) =>
                              v!.isEmpty ? 'Required' : null,
                            ),

                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                style: const TextStyle(
                                    color: Colors.redAccent),
                              ),
                            ],

                            const SizedBox(height: 24),

                            GemButton(
                              label: 'Create Account',
                              onPressed: _register,
                              loading: _loading,
                            ),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(color: Colors.white),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const SignInScreen(),
                                    ),
                                  ),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}