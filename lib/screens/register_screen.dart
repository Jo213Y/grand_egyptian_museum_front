import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/button.dart';
import '../widgets/common_widgets.dart';
import '../services/api_service.dart';
import '../utils/app_assets.dart';
import '../widgets/input_field.dart';
import 'signin_screen.dart';
import 'home_screen.dart';

// ── Country data ──────────────────────────────────────────────────────────────
class _Country {
  final String name;
  final String flag;
  final bool isEgypt;
  const _Country(this.name, this.flag, {this.isEgypt = false});
}

const List<_Country> _kCountries = [
  _Country('Egypt',               '🇪🇬', isEgypt: true),
  _Country('Afghanistan',         '🇦🇫'),
  _Country('Albania',             '🇦🇱'),
  _Country('Algeria',             '🇩🇿'),
  _Country('Argentina',           '🇦🇷'),
  _Country('Armenia',             '🇦🇲'),
  _Country('Australia',           '🇦🇺'),
  _Country('Austria',             '🇦🇹'),
  _Country('Azerbaijan',          '🇦🇿'),
  _Country('Bahrain',             '🇧🇭'),
  _Country('Bangladesh',          '🇧🇩'),
  _Country('Belarus',             '🇧🇾'),
  _Country('Belgium',             '🇧🇪'),
  _Country('Bolivia',             '🇧🇴'),
  _Country('Bosnia',              '🇧🇦'),
  _Country('Brazil',              '🇧🇷'),
  _Country('Bulgaria',            '🇧🇬'),
  _Country('Cambodia',            '🇰🇭'),
  _Country('Cameroon',            '🇨🇲'),
  _Country('Canada',              '🇨🇦'),
  _Country('Chile',               '🇨🇱'),
  _Country('China',               '🇨🇳'),
  _Country('Colombia',            '🇨🇴'),
  _Country('Croatia',             '🇭🇷'),
  _Country('Cuba',                '🇨🇺'),
  _Country('Cyprus',              '🇨🇾'),
  _Country('Czech Republic',      '🇨🇿'),
  _Country('Denmark',             '🇩🇰'),
  _Country('Ecuador',             '🇪🇨'),
  _Country('Ethiopia',            '🇪🇹'),
  _Country('Finland',             '🇫🇮'),
  _Country('France',              '🇫🇷'),
  _Country('Georgia',             '🇬🇪'),
  _Country('Germany',             '🇩🇪'),
  _Country('Ghana',               '🇬🇭'),
  _Country('Greece',              '🇬🇷'),
  _Country('Hungary',             '🇭🇺'),
  _Country('India',               '🇮🇳'),
  _Country('Indonesia',           '🇮🇩'),
  _Country('Iran',                '🇮🇷'),
  _Country('Iraq',                '🇮🇶'),
  _Country('Ireland',             '🇮🇪'),
  _Country('Italy',               '🇮🇹'),
  _Country('Japan',               '🇯🇵'),
  _Country('Jordan',              '🇯🇴'),
  _Country('Kazakhstan',          '🇰🇿'),
  _Country('Kenya',               '🇰🇪'),
  _Country('Kuwait',              '🇰🇼'),
  _Country('Lebanon',             '🇱🇧'),
  _Country('Libya',               '🇱🇾'),
  _Country('Malaysia',            '🇲🇾'),
  _Country('Mexico',              '🇲🇽'),
  _Country('Morocco',             '🇲🇦'),
  _Country('Netherlands',         '🇳🇱'),
  _Country('New Zealand',         '🇳🇿'),
  _Country('Nigeria',             '🇳🇬'),
  _Country('Norway',              '🇳🇴'),
  _Country('Oman',                '🇴🇲'),
  _Country('Pakistan',            '🇵🇰'),
  _Country('Palestine',           '🇵🇸'),
  _Country('Peru',                '🇵🇪'),
  _Country('Philippines',         '🇵🇭'),
  _Country('Poland',              '🇵🇱'),
  _Country('Portugal',            '🇵🇹'),
  _Country('Qatar',               '🇶🇦'),
  _Country('Romania',             '🇷🇴'),
  _Country('Russia',              '🇷🇺'),
  _Country('Saudi Arabia',        '🇸🇦'),
  _Country('Senegal',             '🇸🇳'),
  _Country('Serbia',              '🇷🇸'),
  _Country('Singapore',           '🇸🇬'),
  _Country('Somalia',             '🇸🇴'),
  _Country('South Africa',        '🇿🇦'),
  _Country('South Korea',         '🇰🇷'),
  _Country('Spain',               '🇪🇸'),
  _Country('Sri Lanka',           '🇱🇰'),
  _Country('Sudan',               '🇸🇩'),
  _Country('Sweden',              '🇸🇪'),
  _Country('Switzerland',         '🇨🇭'),
  _Country('Syria',               '🇸🇾'),
  _Country('Taiwan',              '🇹🇼'),
  _Country('Tanzania',            '🇹🇿'),
  _Country('Thailand',            '🇹🇭'),
  _Country('Tunisia',             '🇹🇳'),
  _Country('Turkey',              '🇹🇷'),
  _Country('Ukraine',             '🇺🇦'),
  _Country('United Arab Emirates','🇦🇪'),
  _Country('United Kingdom',      '🇬🇧'),
  _Country('United States',       '🇺🇸'),
  _Country('Uruguay',             '🇺🇾'),
  _Country('Uzbekistan',          '🇺🇿'),
  _Country('Venezuela',           '🇻🇪'),
  _Country('Vietnam',             '🇻🇳'),
  _Country('Yemen',               '🇾🇪'),
];

// ── Country Picker Bottom Sheet ───────────────────────────────────────────────
class _CountryPickerSheet extends StatefulWidget {
  final String? selected;
  const _CountryPickerSheet({this.selected});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _q = '';

  List<_Country> get _filtered => _q.isEmpty
      ? _kCountries
      : _kCountries.where((c) => c.name.toLowerCase().contains(_q.toLowerCase())).toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A0A00),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Title
          const Text('Select Country',
              style: TextStyle(color: AppColors.gold, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(
                hintText: 'Search country...',
                hintStyle: const TextStyle(color: Colors.white30),
                prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 20),
                suffixIcon: _q.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                  onPressed: () { _searchCtrl.clear(); setState(() => _q = ''); },
                )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold, width: 1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          const Divider(color: Colors.white10, height: 1),

          // List
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No results', style: TextStyle(color: Colors.white38)))
                : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final c = filtered[i];
                final isSelected = c.name == widget.selected;
                return InkWell(
                  onTap: () => Navigator.pop(context, c.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                      border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04))),
                    ),
                    child: Row(children: [
                      Text(c.flag, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(c.name,
                            style: TextStyle(
                              color: isSelected ? AppColors.gold : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            )),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppColors.gold, size: 18),
                    ]),
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

// ── Register Screen ───────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl        = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _passCtrl        = TextEditingController();
  final _confirmCtrl     = TextEditingController();
  final _nationalIdCtrl  = TextEditingController();
  final _passportCtrl    = TextEditingController();

  bool    _loading = false;
  String? _error;
  String? _selectedCountry;

  _Country? get _country =>
      _selectedCountry == null ? null : _kCountries.firstWhere((c) => c.name == _selectedCountry);

  bool get _isEgypt => _country?.isEgypt == true;

  Future<void> _openCountryPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => _CountryPickerSheet(selected: _selectedCountry),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCountry = result;
        _nationalIdCtrl.clear();
        _passportCtrl.clear();
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.register(
        fullName:      _nameCtrl.text.trim(),
        email:         _emailCtrl.text.trim(),
        password:      _passCtrl.text,
        phone:         _phoneCtrl.text.trim(),
        country:       _selectedCountry,
        nationalId:    _isEgypt ? _nationalIdCtrl.text : null,
        passportNumber: !_isEgypt && _selectedCountry != null ? _passportCtrl.text : null,
      );
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                children: [
                  Image.asset(AppAssets.logoGold, width: 90, height: 90),
                  const SizedBox(height: 32),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Create Account',
                                style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 28),

                            GemTextField(
                              label: 'Full Name', controller: _nameCtrl,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 14),

                            GemTextField(
                              label: 'Email Address', controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v!.contains('@') ? null : 'Invalid email',
                            ),
                            const SizedBox(height: 14),

                            GemTextField(
                              label: 'Phone Number', controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Phone number is required';
                                final clean = value.replaceAll(RegExp(r'[^\d]'), '');
                                if (!RegExp(r'^01[0-2,5,6,7,8,9]\d{8}$').hasMatch(clean)) return 'Invalid phone number';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // ── Country Picker ──────────────────────────────
                            const SizedBox(height: 28),
                            FormField<String>(
                              validator: (_) => _selectedCountry == null ? 'Select country' : null,
                              builder: (state) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: _openCountryPicker,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: AppColors.inputFill,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: state.hasError
                                              ? Colors.redAccent
                                              : AppColors.primaryLight,
                                          width: state.hasError ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(children: [
                                        if (_country != null)
                                          Text(_country!.flag, style: const TextStyle(fontSize: 20))
                                        else
                                        //  const Icon(Icons.public, color: AppColors.gray, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _selectedCountry ?? 'Select Country',
                                            style: const TextStyle(
                                              color: AppColors.gray,
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.keyboard_arrow_down, color: AppColors.gray, size: 20),
                                      ]),
                                    ),
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6, left: 4),
                                      child: Text(state.errorText!,
                                          style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // ── ID field ────────────────────────────────────
                            if (_isEgypt) ...[
                              GemTextField(
                                label: 'National ID',
                                controller: _nationalIdCtrl,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  if (!RegExp(r'^\d+$').hasMatch(v)) return 'Invalid ID';
                                  if (v.length != 14) return 'Must be 14 digits';
                                  return null;
                                },
                              ),
                            ] else if (_selectedCountry != null) ...[
                              GemTextField(
                                label: 'Passport Number',
                                controller: _passportCtrl,
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ],

                            const SizedBox(height: 14),

                            GemTextField(
                              label: 'Password', controller: _passCtrl, obscure: true,
                              validator: (v) => v!.length >= 6 ? null : 'Min 6 chars',
                            ),
                            const SizedBox(height: 14),

                            GemTextField(
                              label: 'Confirm Password', controller: _confirmCtrl, obscure: true,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),

                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                            ],

                            const SizedBox(height: 24),

                            GemButton(label: 'Create Account', onPressed: _register, loading: _loading),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Already have an account? ', style: TextStyle(color: Colors.white)),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (_) => const SignInScreen())),
                                  child: const Text('Sign In',
                                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
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