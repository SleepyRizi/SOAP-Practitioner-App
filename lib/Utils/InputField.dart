import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  /// Optional form-level validator
  final String? Function(String?)? validator;

  /// Hide text (e.g. for passwords). Default = false.
  final bool obscure;

  /// Keyboard type. Default = TextInputType.text.
  final TextInputType textInputType;

  /// Optional trailing widget (eye icon, etc.).
  final Widget? suffix;

  const InputField({
    super.key,
    required this.hint,
    required this.controller,
    this.validator,
    this.obscure = false,
    this.textInputType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: textInputType,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFDADADA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFDADADA)),
        ),
      ),
    );
  }
}
