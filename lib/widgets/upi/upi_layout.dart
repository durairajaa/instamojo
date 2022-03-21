import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamojo/bloc/bloc.dart';
import 'package:instamojo/controllers/instamojo_controller.dart';
import 'package:instamojo/models/payment_option_model.dart';
import 'package:instamojo/repositories/respositories.dart';

import '../../utils.dart';

class UpiLayout extends StatefulWidget {
  final String? title;
  final UpiOptions? upiOptions;
  final String? amount;
  final InstamojoRepository? repository;
  final InstamojoPaymentStatusListener? listener;

  const UpiLayout(
      {Key? key,
      this.title,
      this.upiOptions,
      this.amount,
      this.repository,
      this.listener})
      : super(key: key);
  @override
  _UpiLayoutState createState() => _UpiLayoutState();
}

class _UpiLayoutState extends State<UpiLayout> {
  String? vpa;
  late BuildContext _context;
  bool? apiCalling;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  late String statusCheckUrl, paymentId;
  late Timer periodicTimer;
  var bloc;
  late Widget preLayout, postLayout;

  @override
  void initState() {
    apiCalling = false;
    statusCheckUrl = "";
    paymentId = "";
    super.initState();
  }

  @override
  void dispose() {
    try {
      if (_context != null) BlocProvider.of<InstamojoBloc>(_context).close();
    } catch (e) {}
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    try {
      if (_context != null) BlocProvider.of<InstamojoBloc>(_context).close();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? hintStyle = stylingDetails.inputFieldTextStyle?.hintTextStyle;
    TextStyle? labelStyle = stylingDetails.inputFieldTextStyle?.labelTextStyle;
    TextStyle? textStyle = stylingDetails.inputFieldTextStyle?.textStyle;
    preLayout = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TextFormField(
          style: textStyle,
          decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              hintText: 'Enter your virtual payment address',
              labelText: 'Enter your virtual payment address',
              hintStyle: hintStyle,
              labelStyle: labelStyle),
          onSaved: (String? value) {
            vpa = value;
          },
          validator: validVPA,
          enabled: !apiCalling!,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          "Example: mohit@icici",
          style: stylingDetails.inputFieldTextStyle?.hintTextStyle,
        ),
        const SizedBox(
          height: 16,
        ),
        _getPayButton(),
        const SizedBox(
          height: 20,
        ),
      ],
    );

    postLayout = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
            child: Image.asset("assets/images/ic_verify_payment.png",
                width: 60, package: "instamojo")),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Waiting...",
          style: stylingDetails.listItemStyle?.textStyle,
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          "You will receive a notification on your Bank UPI app.\nPlease confirm it to complete the payment.",
          style: stylingDetails.listItemStyle?.textStyle,
          textAlign: TextAlign.center,
        )
      ],
    );
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            widget.title as String,
          ),
        ),
        body: BlocProvider(
          create: (ctx) {
            return InstamojoBloc(repository: widget.repository);
          },
          child: SingleChildScrollView(
              child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(16),
                  child: Form(
                      key: _formKey,
                      child: BlocConsumer<InstamojoBloc, InstamojoState>(
                        builder: (context, state) {
                          _context = context;
                          setWidget() {
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[postLayout]);
                          }

                          if (state is InstamojoLoaded) {
                            if (state.loadType == LoadType.CollectUPIPayment) {
                              setWidget();
                            }
                          }
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                if (statusCheckUrl == "") preLayout,
                                if (statusCheckUrl != "") postLayout,
                              ]);
                        },
                        listenWhen: (prev, current) {
                          if (current is InstamojoLoaded ||
                              current is InstamojoError) return true;
                          return false;
                        },
                        listener: (context, state) {
                          if (state is InstamojoLoaded) {
                            if (state.loadType == LoadType.CollectUPIPayment) {
                              Map<String, dynamic> response =
                                  jsonDecode(state.collectUPIRequest as String);
                              if (response.containsKey("statusCode") &&
                                  response['statusCode'] == 400) {
                                _showInSnackBar(
                                    "Oops. Some error occurred with the VPA $vpa. Please try again..",
                                    null);
                              } else {
                                if (response["status_code"] != 2) {
                                  _showInSnackBar("Please try again", null);
                                  return;
                                }
                              }
                              statusCheckUrl = response["status_check_url"];
                              paymentId = response["payment_id"];
                              BlocProvider.of<InstamojoBloc>(_context)
                                  .add(GetUPIStatusEvent(url: statusCheckUrl));
                            } else if (state.loadType ==
                                LoadType.GetUPIStatus) {
                              dynamic response =
                                  jsonDecode(state.getUPIStatus as String);
                              if (response["status_code"] != 2) {
                                apiCalling = false;

                                Map<String, String> map = {};
                                if (response['status_code'] == 6) {
                                  map["statusCode"] = "201";
                                  map["response"] = "Payment Failed";
                                  map["payment_id"] = paymentId;
                                  map["payment_status"] = "UPI";
                                } else {
                                  map["statusCode"] = "200";
                                  map["response"] = "Payment Successful";
                                  map["payment_id"] = paymentId;
                                  map["payment_status"] = "UPI";
                                }
                                Navigator.pop(context);
                                Navigator.pop(context);
                                widget.listener?.paymentStatus(status: map);
                              } else {
                                retryUPIStatusCheck();
                              }
                            }
                          } else if (state is InstamojoError) {
                            setState(() {
                              apiCalling = false;
                            });
                            _showInSnackBar("Something went wrong", null);
                          }
                        },
                      )))),
        ));
  }

  Widget _getPayButton() {
    return SizedBox(
        width: double.maxFinite,
        child: ElevatedButton(
          onPressed: apiCalling!
              ? () {}
              : () {
                  final form = _formKey.currentState;
                  if (form!.validate()) {
                    form.save();
                    BlocProvider.of<InstamojoBloc>(_context).add(
                        CollectUPIPaymentEvent(
                            url: widget.upiOptions!.submissionUrl, vpa: vpa));
                    setState(() {
                      apiCalling = true;
                    });
                  }
                },
          // color: stylingDetails.buttonStyle?.buttonColor,
          // shape: const RoundedRectangleBorder(
          //   borderRadius: BorderRadius.all(Radius.circular(2.0)),
          // ),
          // textColor: Colors.white,
          child: Text(
            "Verify Payment".toUpperCase(),
            style: stylingDetails.buttonStyle?.buttonTextStyle,
          ),
        ));
  }

  retryUPIStatusCheck() async {
    Future.delayed(
        const Duration(
          seconds: 2,
        ), () {
      if (mounted && _context != null) {
        try {
          BlocProvider.of<InstamojoBloc>(_context)
              .add(GetUPIStatusEvent(url: statusCheckUrl));
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    });
  }

  void _showInSnackBar(String value, SnackBarAction? action) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value),
        duration: const Duration(seconds: 3),
        action: action,
      ));
    }
  }

  String? validVPA(String? value) {
    Pattern pattern =
        // r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        r'^\w+@\w+$';

    RegExp regex = RegExp(pattern.toString());
    if (regex.hasMatch(value!)) {
      List splitData = value.split("@");
      if (splitData.length != 2) {
        return 'Enter Valid VPA';
      }
    } else {
      return 'Enter Valid VPA';
    }
    return null;
  }
}
