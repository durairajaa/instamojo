import 'dart:collection';

import 'package:instamojo/widgets/card/payment_card.dart';

Map<String, String> populateCardRequest({
  String? orderId,
  String? merchandId,
  PaymentCard? card,
  EmiOptions? emiOptions,
}) {
  if (CardUtils.getCardTypeFrmNumber(card?.number as String) ==
      CardType.Maestro) {
    card?.month ??= 12;
    if (card?.year == null) {
      card?.month = 49;
    }

    card?.cvv ??= 111;
  }
  LinkedHashMap<String, String> fieldMap = new LinkedHashMap();
  fieldMap["order_id"] = orderId!;
  fieldMap["merchant_id"] = merchandId!;
  fieldMap["payment_method_type"] = "CARD";
  fieldMap["card_number"] = card!.number!;
  fieldMap["card_exp_month"] = card.month.toString();
  fieldMap["card_exp_year"] = card.year.toString();
  fieldMap["card_security_code"] = card.cvv.toString();
  fieldMap["save_to_locker"] = "false";
  fieldMap["redirect_after_payment"] = "true";
  fieldMap["format"] = "json";

  if (card.name != null) {
    fieldMap["name_on_card"] = card.name!;
  }

  if (emiOptions != null && emiOptions.emibankCode != null) {
    fieldMap["is_emi"] = "true";
    fieldMap["emi_bank"] = emiOptions.emibankCode.toString();
    fieldMap["emi_tenure"] = emiOptions.emiTenure.toString();
  }

  return fieldMap;
}

class EmiOptions {
  final String? emibankCode;
  final int? emiTenure;

  EmiOptions({this.emibankCode, this.emiTenure});
}
