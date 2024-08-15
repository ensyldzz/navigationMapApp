import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.obscureText = false,
      this.validator,
      this.prefixIcon,
      this.keyboardType = TextInputType.text,
      this.maxLength,
      this.helperText,
      this.maxLines});

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final int? maxLength;
  final Text? helperText;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        maxLines: obscureText ? 1 : maxLines,
        maxLength: maxLength,
        textInputAction: TextInputAction.next,
        keyboardType: keyboardType,
        validator: validator,
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          helper: helperText,
          prefixIcon: prefixIcon,
          hintText: hintText,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
            Radius.circular(12),
          )),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2),
          ),
        ),
      ),
    );
  }
}
