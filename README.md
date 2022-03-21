# Instamojo Plugin

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![pub package](https://img.shields.io/badge/pub-v1.0.0%2B1-brightgreen)](https://pub.dev/packages/flutter_instamojo)

Plugin to implement Instamojo Payment Gateway on your flutter app

*Note*: This plugin is still under active development, and some Zoom features might not be available yet. We are working to add more features.
Feedback, Pull Requests are always welcome.

*Note*: For Android and iOS Build import.
```shell script
import 'package:instamojo/instamojo.dart';
```

## Features

- [x] Based on Instamojo API
- [x] Null Safety.
- [x] Stream Payment Status with Proper Message.
- [x] UPI Payment Supported.
- [x] Login Error with proper Error codes.
- [x] All payment options accepted including wallets.
- [x] iOS & Android Support.
- [x] Web Support.
- [x] Customized Styling.
- [ ] UI Improvements.
- [ ] UPI App Integration.

## Installation

First, add `instamojo: ^1.0.0+1` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

*Note*: For Live Mode SDK Server setup is required. You can find sample sdk server code below.

- Link to Sample Server Sdk [Sample SDK Server](https://github.com/Instamojo/sample-sdk-server).

## Examples

## Instamojo Screen For Payment Initialization Test Mode
```dart
class InstamojoScreen extends StatefulWidget {
  final CreateOrderBody? body;
  final String? orderCreationUrl;
  final bool? isLive;

  const InstamojoScreen(
      {Key? key, this.body, this.orderCreationUrl, this.isLive = false})
      : super(key: key);

  @override
  _InstamojoScreenState createState() => _InstamojoScreenState();
}

class _InstamojoScreenState extends State<InstamojoScreen>
    implements InstamojoPaymentStatusListener {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Instamojo Flutter'),
        ),
        body: SafeArea(
            child: FlutterInstamojo(
          isConvenienceFeesApplied: false,
          listener: this,
          environment: widget.isLive! ? Environment.PRODUCTION : Environment.TEST,
          apiCallType: ApiCallType.createOrder(
              createOrderBody: widget.body,
              orderCreationUrl: widget.orderCreationUrl),
          stylingDetails: StylingDetails(
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
              )),
        )));
  }

  @override
  void paymentStatus({Map<String, String>? status}) {
    Navigator.pop(context, status);
  }
}
```

## Instamojo Screen For Payment Initialization Live Mode 
For Live Mode Need to Invoke `ApiCallType.startPayment(orderId: "")`

```dart
class InstamojoScreen extends StatefulWidget {
  final CreateOrderBody? body;
  final String? orderCreationUrl;
  final bool? isLive;
  final String name;
  final String orderId;

  const InstamojoScreen(
      {Key? key, this.body, this.orderCreationUrl, this.isLive = false, this.name, this.orderId})
      : super(key: key);

  @override
  _InstamojoScreenState createState() => _InstamojoScreenState();
}

class _InstamojoScreenState extends State<InstamojoScreen>
    implements InstamojoPaymentStatusListener {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Instamojo Flutter'),
        ),
        body: SafeArea(
            child: FlutterInstamojo(
          isConvenienceFeesApplied: false,
          listener: this,
          environment:Environment.PRODUCTION,
          apiCallType: ApiCallType.startPayment(orderId: widget.orderId), 
          stylingDetails: StylingDetails(
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
              )),
        )));
  }

  @override
  void paymentStatus({Map<String, String>? status}) {
    print(status);
  }
}
```

## Invoke Payment For Testing Purpose Only
```dart
startInstamojo() async {
    dynamic result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => InstamojoScreen(
                  isLive: false,
                  body: CreateOrderBody(
                      buyerName: "EvilRAT Technologies",
                      buyerEmail: "ceo@evilrattechnologies.com",
                      buyerPhone: "+91 7004491831",
                      amount: "300",
                      description: "Test Payment"),
                  orderCreationUrl:
                      "https://sample-sdk-server.instamojo.com/order", // The sample server of instamojo to create order id.
                )));

    setState(() {
      _paymentResponse = result.toString();
    });
}
```

## Invoke Payment For Live Mode
```dart
startInstamojo() async {
    dynamic result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => InstamojoScreen(
                  isLive: true,
                  name: widget.package["name"].toString(),
                  orderId: orderId,
                  isLive: true,
                )
        )
    );

    setState(() {
      _paymentResponse = result.toString();
    });
}
```


## Getting Started With Flutter

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

