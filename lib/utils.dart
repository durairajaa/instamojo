import 'package:flutter/material.dart';

import 'instamojo.dart';

/// Return Is Successful
bool isSuccessful(int statusCode) {
  return statusCode >= 200 && statusCode < 300;
}

/// Styling Utils for plugin
StylingDetails _stylingDetail = StylingDetails(
    buttonStyle: ButtonStyling(
        buttonColor: Colors.amber,
        buttonTextStyle: const TextStyle(
          color: Colors.black,
        )),
    listItemStyle: ListItemStyle(
        borderColor: Colors.grey,
        textStyle: const TextStyle(color: Colors.black, fontSize: 18),
        subTextStyle: const TextStyle(color: Colors.grey, fontSize: 14)),
    loaderColor: Colors.amber,
    inputFieldTextStyle: InputFieldTextStyle(
        textStyle: const TextStyle(color: Colors.black, fontSize: 18),
        hintTextStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        labelTextStyle: const TextStyle(color: Colors.grey, fontSize: 14)),
    alertStyle: AlertStyle(
      headingTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
      messageTextStyle: const TextStyle(color: Colors.black, fontSize: 12),
      positiveButtonTextStyle:
          const TextStyle(color: Colors.redAccent, fontSize: 10),
      negativeButtonTextStyle:
          const TextStyle(color: Colors.amber, fontSize: 10),
    ));

StylingDetails get stylingDetails => _stylingDetail;

set stylingDetails(StylingDetails details) {
  _stylingDetail = details;
}
