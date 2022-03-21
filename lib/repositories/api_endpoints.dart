const String LIVE_URL = "https://api.instamojo.com/";
const String TEST_URL = "https://test.instamojo.com/";
const String DEFAULT_ORDER_CREATION_URL =
    "https://sample-sdk-server.instamojo.com";

String paymentMethodsEndpoint(String orderId) {
  return "v2/gateway/orders/$orderId/checkout-options/";
}

String getpaymentMethods(String url, String orderId) {
  return "$url${paymentMethodsEndpoint(orderId)}";
}
