import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:instamojo/models/models.dart';
import 'package:instamojo/repositories/respositories.dart';
import 'package:http/http.dart' as http;

import '../instamojo.dart';
import '../utils.dart';

class InstamojoApiClient {
  http.Client httpClient = http.Client();
  final Environment environment;
  final String _baseUrl;
  InstamojoApiClient({this.environment = Environment.TEST})
      : _baseUrl = environment == Environment.PRODUCTION ? LIVE_URL : TEST_URL;
  Future<PaymentOptionModel> createOrder(CreateOrderBody? body,
      {String? orderCreationUrl}) async {
    final url = orderCreationUrl ?? DEFAULT_ORDER_CREATION_URL;
    final response = await httpClient.post(Uri.parse(url),
        body: createOrderBodyToJson(
            body!,
            environment
                .toString()
                .substring(environment.toString().indexOf('.') + 1)),
        headers: {"Content-Type": "application/json"});

    if (response.statusCode != 200) {
      throw Exception('error creating order');
    }

    final json = jsonDecode(response.body);
    if (kDebugMode) {
      print(json);
    }
    var model = CreatedOrderModel.fromJson(json);
    return await fetchOrder(model.orderId);
  }

  Future<PaymentOptionModel> fetchOrder(String? orderId) async {
    final response =
        await httpClient.get(Uri.parse(getpaymentMethods(_baseUrl, orderId!)));

    if (response.statusCode != 200) {
      print("instamojo error status ${response.statusCode}  ${response.body}");
      print("instamojo error ${jsonDecode(response.body)}");
      throw Exception('error creating order');
    }

    final json = jsonDecode(response.body);
    if (kDebugMode) {
      print(json);
    }
    return PaymentOptionModel.fromJson(json);
  }

  Future<String> getUPIStatus(String url) async {
    final response = await httpClient.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('error creating order');
    }

    final json = jsonDecode(response.body);
    if (kDebugMode) {
      print(json);
    }
    return response.body;
  }

  Future<String> collectCardpayment(
      String url, Map<String, String>? cardPaymentRequest) async {
    final response = await httpClient.post(Uri.parse(url),
        body: cardPaymentRequest,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        encoding: Encoding.getByName("utf-8"));

    if (response.statusCode != 200) {
      throw Exception('error creating order');
    }
    final json = jsonDecode(response.body);
    if (kDebugMode) {
      print(json);
    }
    return response.body;
  }

  Future<String> collectUPIPayment(String url, String vpa) async {
    final response = await httpClient.post(Uri.parse(url),
        body: {"virtual_address": vpa},
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        encoding: Encoding.getByName("utf-8"));

    String result = response.body;

    if (!isSuccessful(response.statusCode)) {
      throw Exception('error creating order');
    } else if (response.statusCode == 400) {
      result = jsonEncode('{"statusCode" : 400}');
    }
    final json = jsonDecode(result);
    if (kDebugMode) {
      print(json);
    }
    return result;
  }
}
