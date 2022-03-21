import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:instamojo/controllers/instamojo_controller.dart';

import '../utils.dart';
import 'loader.dart';

class Browser extends StatefulWidget {
  final String? url;
  final InstamojoPaymentStatusListener? listener;
  final String? postData;
  const Browser({Key? key, this.url, this.listener, this.postData})
      : super(key: key);

  @override
  _BrowserState createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webView;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));
  String url = "";
  int? webProgress;
  bool? showLoader;

  @override
  void initState() {
    webProgress = 0;
    showLoader = true;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Payment"),
        ),
        body: WillPopScope(
            onWillPop: () {
              _showDialog(context, widget.listener);
              return Future.value(false);
            },
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Expanded(
                        child: InAppWebView(
                      initialOptions: options,
                      onWebViewCreated: (controller) async {
                        webView = controller;
                        Future.delayed(const Duration(milliseconds: 200), () {
                          if (widget.postData != null) {
                            controller.postUrl(
                                url: Uri.parse(widget.url as String),
                                postData: Uint8List.fromList(
                                    widget.postData!.codeUnits));
                          } else {
                            controller.loadUrl(
                                urlRequest: URLRequest(
                                    url: Uri.parse(widget.url as String)));
                          }
                        });
                        if (kDebugMode) {
                          print("onWebViewCreated");
                        }
                      },
                      onLoadStart: (controller, url) {
                        if (kDebugMode) {
                          print("onLoadStart $url");
                        }
                        setState(() {
                          this.url = url.toString();
                        });
                      },
                      onLoadStop: (controller, url) async {
                        if (kDebugMode) {
                          print("onLoadStop $url");
                        }
                        setState(() {
                          this.url = url.toString();
                        });
                        if (url
                            .toString()
                            .contains("/integrations/android/redirect")) {
                          String value = url.toString().split("?")[1];
                          List<String> values = value.split("&");
                          Map<String, String> map = {};
                          for (int i = 0; i < values.length; i++) {
                            map[values[i].split("=")[0]] =
                                values[i].split("=")[1];
                          }
                          if (map.containsKey("payment_status") &&
                              map["payment_status"]!.toLowerCase() ==
                                  "failed") {
                            map["statusCode"] = "201";
                            map["response"] = "Payment Failed";
                          } else {
                            map["statusCode"] = "200";
                            map["response"] = "Payment Successful";
                          }

                          if (kDebugMode) {
                            print(map.toString());
                          }
                          Navigator.pop(context);
                          Navigator.pop(context);
                          widget.listener?.paymentStatus(status: map);
                        }
                      },
                      onProgressChanged:
                          (InAppWebViewController controller, int progress) {
                        // if (webProgress < 90)
                        setState(() {
                          webProgress = progress;
                          if (kDebugMode) {
                            print(webProgress);
                          }
                        });
                      },
//                          onUpdateVisitedHistory:
//                              (InAppWebViewController controller, String url,
//                                  bool androidIsReload) {
//                            print("onUpdateVisitedHistory $url");
//                            setState(() {
//                              this.url = url;
//                            });
//                          }),
                    )),
                  ],
                ),
                Visibility(
                  visible: webProgress! < 90,
                  child: Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    color: Colors.white,
                    child: const Loader(),
                  ),
                )
              ],
            )));
  }
}

_showDialog(
    BuildContext context, InstamojoPaymentStatusListener? listener) async {
  englishButtons() {
    return <Widget>[
      ElevatedButton(
          child: Text(
            "Yes",
            style: stylingDetails.alertStyle?.positiveButtonTextStyle,
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            listener?.paymentStatus(status: {
              "statusCode": "201",
              "response": "Payment Cancelled By User"
            });
          }),
      ElevatedButton(
          child: Text(
            "No",
            style: stylingDetails.alertStyle?.negativeButtonTextStyle,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
    ];
  }

  String? result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      titleWidget() {
        return Text(
          "Alert",
          style: stylingDetails.alertStyle?.headingTextStyle,
        );
      }

      messageWidget() {
        return Text(
          "Are you sure you want to cancel this payment?",
          style: stylingDetails.alertStyle?.messageTextStyle,
        );
      }

      actionWidget() {
        return englishButtons();
      }

      return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: Platform.isIOS
              ? CupertinoAlertDialog(
                  title: titleWidget(),
                  content: messageWidget(),
                  actions: actionWidget(),
                )
              : AlertDialog(
                  title: titleWidget(),
                  content: messageWidget(),
                  actions: actionWidget(),
                ));
    },
  );
  if (result == "failed") {}
}
