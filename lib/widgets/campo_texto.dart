import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icone;
  final bool obscureText;
  final bool soLeitura;
  final int maxLines;
  final TextInputType? teclado;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validador;
  final Widget? suffixIcon;

  const CampoTexto({
    super.key,
    required this.label,
    required this.controller,
    required this.icone,
    this.obscureText = false,
    this.soLeitura = false,
    this.maxLines = 1,
    this.teclado,
    this.formatters,
    this.validador,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: soLeitura,
      maxLines: maxLines,
      keyboardType: teclado,
      inputFormatters: formatters,
      validator: validador,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
