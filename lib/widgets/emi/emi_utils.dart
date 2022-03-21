import 'package:decimal/decimal.dart';
import 'dart:math' as Math;

getEmiAmount(String totalAmount, String interestRate, int tenure) {
  double parsedAmount = double.parse(totalAmount);
  return getMonthlyEMI(parsedAmount, Decimal.parse(interestRate), tenure);
}

getTotalAmount(double emiAmount, int tenure) {
  return getRoundedValue(emiAmount * tenure, 2);
}

double getMonthlyEMI(double amount, Decimal rate, int tenure) {
  double perRate = rate.toDouble() / 1200;
  double emiAmount =
      amount * perRate / (1 - Math.pow((1 / (1 + perRate)), tenure));
  return getRoundedValue(emiAmount, 2);
}

double getRoundedValue(double value, int precision) {
  return double.parse(value.toStringAsFixed(precision));
}
