import 'package:flutter/material.dart';

Future<void> explanationDialog(BuildContext context, String title, Widget explanation) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              explanation
            ]
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Ok',
              style: TextStyle(
                color: Colors.black.withAlpha(150),
                fontSize: 20,
              ),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}