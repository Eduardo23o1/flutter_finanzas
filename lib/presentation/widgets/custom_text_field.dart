import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputValidationType { none, email, number, textOnly, password }

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final String? Function(String?)? validator;
  final InputValidationType inputType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.validator,
    this.inputType = InputValidationType.none,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  String? _defaultValidator(String? value) {
    final val = value?.trim() ?? '';

    if (val.isEmpty) {
      return 'Este campo es obligatorio';
    }

    switch (widget.inputType) {
      case InputValidationType.email:
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(val)) return 'Correo electrónico inválido';
        break;

      case InputValidationType.number:
        if (double.tryParse(val) == null) return 'Ingrese solo números válidos';
        break;

      case InputValidationType.textOnly:
        final textRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
        if (!textRegex.hasMatch(val)) return 'Ingrese solo letras';
        break;

      case InputValidationType.password:
        if (val.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        break;

      case InputValidationType.none:
        break;
    }

    return null;
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.inputType) {
      case InputValidationType.number:
        return [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
      case InputValidationType.textOnly:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
        ];
      default:
        return null;
    }
  }

  TextInputType _getKeyboardType() {
    switch (widget.inputType) {
      case InputValidationType.email:
        return TextInputType.emailAddress;
      case InputValidationType.number:
        return TextInputType.number;
      case InputValidationType.password:
        return TextInputType.visiblePassword;
      case InputValidationType.textOnly:
      case InputValidationType.none:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator ?? _defaultValidator,
      keyboardType: _getKeyboardType(),
      inputFormatters: _getInputFormatters(),
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : null,
      ),
    );
  }
}
