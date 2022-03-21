import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

PaymentOptionModel paymentOptionModelFromJson(String str) =>
    PaymentOptionModel.fromJson(json.decode(str));

String paymentOptionModelToJson(PaymentOptionModel data) =>
    json.encode(data.toJson());

class PaymentOptionModel extends Equatable {
  final Order? order;
  final PaymentOptions? paymentOptions;

  const PaymentOptionModel({
    this.order,
    this.paymentOptions,
  });

  factory PaymentOptionModel.fromJson(Map<String, dynamic> json) =>
      PaymentOptionModel(
        order: json["order"] == null ? null : Order.fromJson(json["order"]),
        paymentOptions: json["payment_options"] == null
            ? null
            : PaymentOptions.fromJson(json["payment_options"]),
      );

  Map<String, dynamic> toJson() => {
        "order": order == null ? null : order?.toJson(),
        "payment_options":
            paymentOptions == null ? null : paymentOptions?.toJson(),
      };

  @override
  List<Object?> get props => [order, paymentOptions];
}

class Order {
  final String? amount;
  OrderWithFees? totalAmountDetails;

  Order({
    this.amount,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        amount: json["amount"] == null ? null : json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount == null ? null : amount,
      };

  get totalOrderAmountDetails {
    OrderWithFees oo = new OrderWithFees();
    double value = (double.parse(this.amount as String));
    double covinenceFeesWithAdditionalValue = ((double.parse(
                this.amount as String) *
            (double.parse(oo.convinenceFeesValueDetails.percentage) / 100)) +
        double.parse(oo.convinenceFeesValueDetails.additiveAdditionalAmount));
    double gstAmount = covinenceFeesWithAdditionalValue *
        (double.parse(oo.gstPercent as String) / 100);
    double total = value + covinenceFeesWithAdditionalValue + gstAmount;
    oo.orderWithConvinenceFees = total.toStringAsFixed(2);
    oo.totalConvinenceFees =
        (covinenceFeesWithAdditionalValue + gstAmount).toStringAsFixed(2);
    oo.convinenceFees = covinenceFeesWithAdditionalValue.toStringAsFixed(2);
    oo.gstFees = gstAmount.toStringAsFixed(2);
    return oo;
  }
}

class OrderWithFees {
  String? orderWithConvinenceFees;
  String? totalConvinenceFees;
  String? convinenceFees;
  ConvinenceFeesValues? convinenceFeesValue;
  String? gstPercent;
  String? gstFees;

  OrderWithFees(
      {this.orderWithConvinenceFees,
      this.totalConvinenceFees,
      this.convinenceFees,
      this.gstPercent = "18.0",
      this.convinenceFeesValue,
      this.gstFees});

  get getGSTPercent {
    return this.gstPercent;
  }

  get convinenceFeesValueDetails {
    ConvinenceFeesValues v = new ConvinenceFeesValues();
    return v;
  }
}

class ConvinenceFeesValues {
  final String percentage;
  final String additiveAdditionalAmount;

  ConvinenceFeesValues(
      {this.percentage = "3.0", this.additiveAdditionalAmount = "3.0"});
}

class PaymentOptions {
  final String? paymentUrl;
  final Options? cardOptions;
  final Options? emiOptions;
  final NetbankingOptions? netbankingOptions;
  final WalletOptions? walletOptions;
  final UpiOptions? upiOptions;

  PaymentOptions({
    this.paymentUrl,
    this.cardOptions,
    this.emiOptions,
    this.netbankingOptions,
    this.walletOptions,
    this.upiOptions,
  });

  factory PaymentOptions.fromJson(Map<String, dynamic> json) => PaymentOptions(
        paymentUrl: json["payment_url"] == null ? null : json["payment_url"],
        cardOptions: json["card_options"] == null
            ? null
            : Options.fromJson(json["card_options"]),
        emiOptions: json["emi_options"] == null
            ? null
            : Options.fromJson(json["emi_options"]),
        netbankingOptions: json["netbanking_options"] == null
            ? null
            : NetbankingOptions.fromJson(json["netbanking_options"]),
        walletOptions: json["wallet_options"] == null
            ? null
            : WalletOptions.fromJson(json["wallet_options"]),
        upiOptions: json["upi_options"] == null
            ? null
            : UpiOptions.fromJson(json["upi_options"]),
      );

  Map<String, dynamic> toJson() => {
        "payment_url": paymentUrl == null ? null : paymentUrl,
        "card_options": cardOptions == null ? null : cardOptions?.toJson(),
        "emi_options": emiOptions == null ? null : emiOptions?.toJson(),
        "netbanking_options":
            netbankingOptions == null ? null : netbankingOptions?.toJson(),
        "wallet_options":
            walletOptions == null ? null : walletOptions?.toJson(),
        "upi_options": upiOptions == null ? null : upiOptions?.toJson(),
      };
}

class Options {
  final String? submissionMethod;
  final CardOptionsSubmissionData? submissionData;
  final String? submissionUrl;
  final List<EmiList>? emiList;

  Options({
    this.submissionMethod,
    this.submissionData,
    this.submissionUrl,
    this.emiList,
  });

  factory Options.fromJson(Map<String, dynamic> json) => Options(
        submissionMethod: json["submission_method"] == null
            ? null
            : json["submission_method"],
        submissionData: json["submission_data"] == null
            ? null
            : CardOptionsSubmissionData.fromJson(json["submission_data"]),
        submissionUrl:
            json["submission_url"] == null ? null : json["submission_url"],
        emiList: json["emi_list"] == null
            ? null
            : List<EmiList>.from(
                json["emi_list"].map((x) => EmiList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "submission_method": submissionMethod == null ? null : submissionMethod,
        "submission_data":
            submissionData == null ? null : submissionData?.toJson(),
        "submission_url": submissionUrl == null ? null : submissionUrl,
        "emi_list": emiList == null
            ? null
            : List<dynamic>.from(emiList!.map((x) => x.toJson())),
      };
}

class EmiList {
  final String? bankName;
  final String? bankCode;
  final List<Rate>? rates;

  EmiList({
    this.bankName,
    this.bankCode,
    this.rates,
  });

  factory EmiList.fromJson(Map<String, dynamic> json) => EmiList(
        bankName: json["bank_name"] == null ? null : json["bank_name"],
        bankCode: json["bank_code"] == null ? null : json["bank_code"],
        rates: json["rates"] == null
            ? null
            : List<Rate>.from(json["rates"].map((x) => Rate.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "bank_name": bankName == null ? null : bankName,
        "bank_code": bankCode == null ? null : bankCode,
        "rates": rates == null
            ? null
            : List<dynamic>.from(rates!.map((x) => x.toJson())),
      };
}

class Rate {
  final int? tenure;
  final double? interest;

  Rate({
    this.tenure,
    this.interest,
  });

  factory Rate.fromJson(Map<String, dynamic> json) => Rate(
        tenure: json["tenure"] == null ? null : json["tenure"],
        interest: json["interest"] == null ? null : json["interest"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "tenure": tenure == null ? null : tenure,
        "interest": interest == null ? null : interest,
      };
}

class CardOptionsSubmissionData {
  final String? merchantId;
  final String? orderId;

  CardOptionsSubmissionData({
    this.merchantId,
    this.orderId,
  });

  factory CardOptionsSubmissionData.fromJson(Map<String, dynamic> json) =>
      CardOptionsSubmissionData(
        merchantId: json["merchant_id"] == null ? null : json["merchant_id"],
        orderId: json["order_id"] == null ? null : json["order_id"],
      );

  Map<String, dynamic> toJson() => {
        "merchant_id": merchantId == null ? null : merchantId,
        "order_id": orderId == null ? null : orderId,
      };
}

class NetbankingOptions {
  final String? submissionMethod;
  final List<NetbankingOptionsChoice>? choices;
  final NetbankingOptionsSubmissionData? submissionData;
  final String? submissionUrl;

  NetbankingOptions({
    this.submissionMethod,
    this.choices,
    this.submissionData,
    this.submissionUrl,
  });

  factory NetbankingOptions.fromJson(Map<String, dynamic> json) =>
      NetbankingOptions(
        submissionMethod: json["submission_method"] == null
            ? null
            : json["submission_method"],
        choices: json["choices"] == null
            ? null
            : List<NetbankingOptionsChoice>.from(json["choices"]
                .map((x) => NetbankingOptionsChoice.fromJson(x))),
        submissionData: json["submission_data"] == null
            ? null
            : NetbankingOptionsSubmissionData.fromJson(json["submission_data"]),
        submissionUrl:
            json["submission_url"] == null ? null : json["submission_url"],
      );

  Map<String, dynamic> toJson() => {
        "submission_method": submissionMethod == null ? null : submissionMethod,
        "choices": choices == null
            ? null
            : List<dynamic>.from(choices!.map((x) => x.toJson())),
        "submission_data":
            submissionData == null ? null : submissionData!.toJson(),
        "submission_url": submissionUrl == null ? null : submissionUrl,
      };
}

class NetbankingOptionsChoice {
  final String? id;
  final String? name;

  NetbankingOptionsChoice({
    this.id,
    this.name,
  });

  factory NetbankingOptionsChoice.fromJson(Map<String, dynamic> json) =>
      NetbankingOptionsChoice(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
      };
}

class NetbankingOptionsSubmissionData {
  NetbankingOptionsSubmissionData();

  factory NetbankingOptionsSubmissionData.fromJson(Map<String, dynamic> json) =>
      NetbankingOptionsSubmissionData();

  Map<String, dynamic> toJson() => {};
}

class UpiOptions {
  final String? submissionMethod;
  final String? submissionUrl;

  UpiOptions({
    this.submissionMethod,
    this.submissionUrl,
  });

  factory UpiOptions.fromJson(Map<String, dynamic> json) => UpiOptions(
        submissionMethod: json["submission_method"] == null
            ? null
            : json["submission_method"],
        submissionUrl:
            json["submission_url"] == null ? null : json["submission_url"],
      );

  Map<String, dynamic> toJson() => {
        "submission_method": submissionMethod == null ? null : submissionMethod,
        "submission_url": submissionUrl == null ? null : submissionUrl,
      };
}

class WalletOptions {
  final String? submissionMethod;
  final List<WalletOptionsChoice>? choices;
  final NetbankingOptionsSubmissionData? submissionData;
  final String? submissionUrl;

  WalletOptions({
    this.submissionMethod,
    this.choices,
    this.submissionData,
    this.submissionUrl,
  });

  factory WalletOptions.fromJson(Map<String, dynamic> json) => WalletOptions(
        submissionMethod: json["submission_method"] == null
            ? null
            : json["submission_method"],
        choices: json["choices"] == null
            ? null
            : List<WalletOptionsChoice>.from(
                json["choices"].map((x) => WalletOptionsChoice.fromJson(x))),
        submissionData: json["submission_data"] == null
            ? null
            : NetbankingOptionsSubmissionData.fromJson(json["submission_data"]),
        submissionUrl:
            json["submission_url"] == null ? null : json["submission_url"],
      );

  Map<String, dynamic> toJson() => {
        "submission_method": submissionMethod == null ? null : submissionMethod,
        "choices": choices == null
            ? null
            : List<dynamic>.from(choices!.map((x) => x.toJson())),
        "submission_data":
            submissionData == null ? null : submissionData?.toJson(),
        "submission_url": submissionUrl == null ? null : submissionUrl,
      };
}

class WalletOptionsChoice {
  final int? id;
  final String? name;
  final String? image;
  final int? type;

  WalletOptionsChoice({
    this.id,
    this.name,
    this.image,
    this.type,
  });

  factory WalletOptionsChoice.fromJson(Map<String, dynamic> json) =>
      WalletOptionsChoice(
        id: json["id"] ?? null,
        name: json["name"] ?? null,
        image: json["image"] ?? null,
        type: json["type"] ?? null,
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "image": image == null ? null : image,
        "type": type == null ? null : type,
      };
}
