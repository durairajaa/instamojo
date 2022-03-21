import 'dart:async';

import 'package:instamojo/models/models.dart';
import 'package:instamojo/repositories/respositories.dart';
import 'package:meta/meta.dart';

class InstamojoRepository {
  final InstamojoApiClient? instamojoApiClient;

  InstamojoRepository({@required this.instamojoApiClient})
      : assert(instamojoApiClient != null);

  Future<PaymentOptionModel> createOrder(CreateOrderBody? body,
      {String? orderCreationUrl}) async {
    return await instamojoApiClient!
        .createOrder(body, orderCreationUrl: orderCreationUrl);
  }

  Future<PaymentOptionModel> initPayment(String? orderId) async {
    return await instamojoApiClient!.fetchOrder(orderId!);
  }

  Future<String> collectCardpayment(
      String url, Map<String, String>? cardPaymentRequest) async {
    return await instamojoApiClient!
        .collectCardpayment(url, cardPaymentRequest);
  }

  Future<String> collectUPIPayment(String? url, String? vpa) async {
    return await instamojoApiClient!.collectUPIPayment(url!, vpa!);
  }

  Future<String> getUPIStatus(String? url) async {
    return await instamojoApiClient!.getUPIStatus(url!);
  }

  Future<List<NetbankingOptionsChoice>> searchBank(
      List<NetbankingOptionsChoice>? banks, String? query) async {
    List<NetbankingOptionsChoice> choices = {} as List<NetbankingOptionsChoice>;
    if (query != null && query.isNotEmpty) {
      for (int i = 0; i < banks!.length; i++) {
        if (banks[i].name!.toLowerCase().contains(query.toLowerCase())) {
          choices.add(banks[i]);
        }
      }
    } else {
      choices = banks!;
    }
    return choices;
  }
}
