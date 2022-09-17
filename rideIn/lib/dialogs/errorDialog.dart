import 'package:flutter/material.dart';

import '../authentication/AppAuthentication.dart';

class ErrorDialog extends StatelessWidget {
  final String errorMessage;

  const ErrorDialog({Key key, this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Text(errorMessage),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Route route =
            MaterialPageRoute(builder: (context) => AppAuthentication());
            Navigator.pushReplacement(context, route);
          },
          child: Center(child: Text("OK")),
        )
      ],
    );
  }
}
