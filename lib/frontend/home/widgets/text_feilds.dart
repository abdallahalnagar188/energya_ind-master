import 'package:flutter/material.dart';
import 'package:energya_ind/core/config/app_colors.dart';

// ignore: must_be_immutable
class TextFeild extends StatefulWidget {
  TextFeild({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.textInputType,
    this.onPressed,
    this.controller,
    this.suffix,
    this.alpha = .5,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.enabled,
    this.readOnly = false,
  });
  final String hintText;
  final IconData prefixIcon;
  IconData? suffixIcon;
  final TextEditingController? controller;
  TextInputType? textInputType;
  final void Function()? onPressed;
  final Widget? suffix;
  final double alpha;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final bool readOnly;
  final bool? enabled;
  @override
  State<TextFeild> createState() => _TextFeildState();
}

class _TextFeildState extends State<TextFeild> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextFormField(
        keyboardType: widget.textInputType,
        controller: widget.controller,
        onChanged: widget.onChanged,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onFieldSubmitted: widget.onFieldSubmitted,
        validator: widget.validator,
        decoration: InputDecoration(
          prefixIcon: Icon(
            widget.prefixIcon,
            size: 18,
          ),
          suffixIcon: widget.suffix ??
              IconButton(
                onPressed: widget.onPressed,
                icon: Icon(
                  widget.suffixIcon,
                  size: 18,
                ),
              ),
          hintText: widget.hintText,
          filled: true,
          // ignore: deprecated_member_use
          fillColor: AppStaticColor.primary.withValues(alpha: widget.alpha),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
