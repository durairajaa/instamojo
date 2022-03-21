import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

CreateOrderBody createOrderBodyFromJson(String str) =>
    CreateOrderBody.fromJson(json.decode(str));

String createOrderBodyToJson(CreateOrderBody? data, String? env) =>
    json.encode(data!.toJson(env!));

class CreateOrderBody extends Equatable {
  final String? amount;
  final String? buyerEmail;
  final String? buyerName;
  final String? buyerPhone;
  final String? description;
  final String? env = "TEST";

  const CreateOrderBody({
    @required this.amount,
    @required this.buyerEmail,
    @required this.buyerName,
    @required this.buyerPhone,
    @required this.description,
  });

  factory CreateOrderBody.fromJson(Map<String, dynamic> json) =>
      CreateOrderBody(
        amount: json["amount"] ?? null,
        buyerEmail: json["buyer_email"] ?? null,
        buyerName: json["buyer_name"] ?? null,
        buyerPhone: json["buyer_phone"] ?? null,
        description: json["description"] ?? "",
      );

  Map<String, String?> toJson(String env) => {
        "amount": amount == null ? null : amount,
        "buyer_email": buyerEmail == null ? null : buyerEmail,
        "buyer_name": buyerName == null ? null : buyerName,
        "buyer_phone": buyerPhone == null ? null : buyerPhone,
        "description": description == null ? null : description,
        "env": env
      };

  @override
  List<Object?> get props => [amount, buyerEmail, buyerName, buyerPhone];
}
