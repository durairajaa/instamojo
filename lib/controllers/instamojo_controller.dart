import 'package:flutter/material.dart';

class InstamojoController {
  final InstamojoPaymentStatusListener? listener;
  InstamojoController({this.listener});
}

abstract class InstamojoPaymentStatusListener {
  void paymentStatus({Map<String, String> status});
}
