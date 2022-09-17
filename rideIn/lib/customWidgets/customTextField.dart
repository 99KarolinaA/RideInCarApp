import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class CustomTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final IconData iconData;
  final String hint;
  final String errorText;
  final String Function(String) validation;
  double errorContentPaddingTop = 21;
  bool isObscure = true;
  Function function;
  CustomTextField(
      {Key key,
      this.textEditingController,
      this.iconData,
      this.hint,
      this.isObscure,
      this.function,
      this.validation,
      this.errorContentPaddingTop,
      this.errorText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        _width = _width;
      } else {
        _width = _width * 0.5;
      }
    } catch (e) {
      _width = _width * 0.5;
    }
    return Container(
      width: _width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(10),
      child: TextFormField(
        onChanged: function,
        validator: validation,
        controller: textEditingController,
        obscureText: isObscure,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
            errorText: errorText,
            contentPadding: EdgeInsets.only(
                top: errorText != null ? errorContentPaddingTop : 10),
            border: InputBorder.none,
            prefixIcon: Icon(
              iconData,
              color: Colors.cyan,
            ),
            focusColor: Theme.of(context).primaryColor,
            hintText: hint),
      ),
    );
  }
}
