import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------------------------- //

// BUILD PATTERN PARA WIDGETS

RaisedButton buildButton(String label, Function f) {
  return RaisedButton(
    onPressed: f,
    disabledColor: Colors.grey,
    disabledTextColor: Colors.white,
    color: Colors.blue,
    textColor: Colors.white,
    child: Text(label),
  );
}
