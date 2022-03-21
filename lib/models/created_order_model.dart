import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

CreatedOrderModel createdOrderModelFromJson(String str) =>
    CreatedOrderModel.fromJson(json.decode(str));

String createdOrderModelToJson(CreatedOrderModel data) =>
    json.encode(data.toJson());

class CreatedOrderModel extends Equatable {
  final String? orderId;
  final String? name;
  final String? email;
  final String? phone;
  final String? amount;

  const CreatedOrderModel({
    @required this.orderId,
    @required this.name,
    @required this.email,
    @required this.phone,
    @required this.amount,
  });

  factory CreatedOrderModel.fromJson(Map<String, dynamic> json) =>
      CreatedOrderModel(
        orderId: json["order_id"] == null ? null : json["order_id"],
        name: json["name"] == null ? null : json["name"],
        email: json["email"] == null ? null : json["email"],
        phone: json["phone"] == null ? null : json["phone"],
        amount: json["amount"] == null ? null : json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId == null ? null : orderId,
        "name": name == null ? null : name,
        "email": email == null ? null : email,
        "phone": phone == null ? null : phone,
        "amount": amount == null ? null : amount,
      };

  @override
  List<Object?> get props => [orderId, name, email, phone, amount];
}
