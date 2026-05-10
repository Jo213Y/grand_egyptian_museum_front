// ── input field  ──────────────
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class GemTextField extends StatefulWidget {
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
  State<GemTextField> createState() => _GemTextFieldState();
}

class _GemTextFieldState extends State<GemTextField> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.label, style: AppTextStyles.label),
      const SizedBox(height: 6),
      TextFormField(
        controller: widget.controller,
        obscureText: _hidden,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        inputFormatters: widget.inputFormatters,
        maxLength: widget.maxLength,
        buildCounter: widget.maxLength != null
            ? (_, {required currentLength, required isFocused, maxLength}) => null
            : null,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: widget.label,
          suffixIcon: widget.obscure
              ? IconButton(
            icon: Icon(
              _hidden ? Icons.visibility_off : Icons.visibility,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => setState(() => _hidden = !_hidden),
          )
              : null,
        ),
      ),
    ]);
  }
}