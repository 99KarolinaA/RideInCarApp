import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final Function(String) onSubmit;
  final String Function(String) validation;
  final TextInputAction textInputAction;
  final bool isPasswordField;
  final FocusNode focusNode;
  final bool isNumberField;
  final Icon icon;
  final double paddingHorizontal;
  TextEditingController controller;
  final errorText;

  CustomInput(
      {Key key,
      this.hintText,
      this.onChanged,
      this.textInputAction = TextInputAction.next,
      this.isPasswordField = false,
      this.focusNode,
      this.isNumberField = false,
      this.controller,
      this.validation,
      this.icon,
      this.paddingHorizontal = 8.0,
      this.onSubmit,
      this.errorText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 19),
        decoration: BoxDecoration(
            // color: const Color(0xfff2f2f2),
            borderRadius: BorderRadius.circular(10)),
        child: TextFormField(
          controller: controller,
          keyboardType:
              isNumberField ? TextInputType.number : TextInputType.text,
          focusNode: focusNode,
          onChanged: onChanged,
          onFieldSubmitted: onSubmit,
          validator: validation,
          textInputAction: textInputAction,
          obscureText: isPasswordField,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
              prefixIcon: icon,
              errorText: errorText,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(.4)),
                  borderRadius: BorderRadius.circular(9)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
              errorBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
              hintText: hintText,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: paddingHorizontal, vertical: 18)),
        ));
  }
}
