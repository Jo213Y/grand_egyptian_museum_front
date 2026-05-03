// ── input field  ──────────────
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class GemTextField extends StatelessWidget {
  final String label;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const GemTextField({
    super.key,
    required this.label,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.label),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        buildCounter: maxLength != null
            ? (_, {required currentLength, required isFocused, maxLength}) => null
            : null,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        decoration: InputDecoration(hintText: label),
      ),
    ]);
  }
}