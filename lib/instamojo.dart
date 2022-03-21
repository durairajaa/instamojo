library flutter_instamojo;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamojo/bloc/instamojo_bloc.dart';
import 'package:instamojo/bloc/instamojo_event.dart';
import 'package:instamojo/bloc/instamojo_state.dart';
import 'package:instamojo/controllers/instamojo_controller.dart';
import 'package:instamojo/models/models.dart';
import 'package:instamojo/repositories/respositories.dart';
import 'package:instamojo/utils.dart';
import 'package:instamojo/widgets/loader.dart';
import 'package:instamojo/widgets/payment_modes.dart';

export './controllers/instamojo_controller.dart';
export './models/create_order_body.dart';

/// Android, iOS & Web Implementation for Instamojo SDK
class Instamojo extends StatefulWidget {
  final Environment environment;
  final ApiCallType apiCallType;
  final InstamojoPaymentStatusListener listener;
  final bool isConvenienceFeesApplied;
  final StylingDetails? stylingDetails;

  const Instamojo(
      {Key? key,
        required this.isConvenienceFeesApplied,
        required this.environment,
        required this.apiCallType,
        this.stylingDetails,
        required this.listener})
      : super(key: key);
  @override
  _InstamojoState createState() => _InstamojoState();
}

class _InstamojoState extends State<Instamojo> {
  late InstamojoRepository repository;
  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('Instamojo called');
    }
    stylingDetails = widget.stylingDetails!;
    BlocOverrides.runZoned(
          () {
        final overrides = BlocOverrides.current;
      },
      blocObserver: SimpleBlocObserver(),
    );
    //Bloc.observer = SimpleBlocObserver();
    repository = InstamojoRepository(
        instamojoApiClient:
        InstamojoApiClient(environment: widget.environment));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          widget.listener.paymentStatus(status: {
            "statusCode": "201",
            "response": "Payment Cancelled By User"
          });
          return Future.value(false);
        },
        child: Scaffold(
          body: BlocProvider(
            create: (context) => InstamojoBloc(repository: repository),
            child: BlocBuilder<InstamojoBloc, InstamojoState>(
              builder: (context, state) {
                if (state is InstamojoEmpty) {
                  if (widget.apiCallType.callType == Type.CREATE_ORDER) {
                    if (kDebugMode) {
                      print('CREATE_ORDER');
                    }
                    context.read<InstamojoBloc>().add(CreateOrder(
                        createOrderBody: widget.apiCallType.createOrderBody,
                        orderCreationUrl: widget.apiCallType.orderCreationUrl));
                  } else if (widget.apiCallType.callType ==
                      Type.START_PAYMENT) {
                    if (kDebugMode) {
                      print('START_PAYMENT');
                    }
                    context
                        .read<InstamojoBloc>()
                        .add(InitPayment(orderId: widget.apiCallType.orderId));
                  }
                }
                if (state is InstamojoError) {
                  return const Center(
                    child: Text('Failed to start payment...'),
                  );
                }
                if (state is InstamojoLoaded) {
                  switch (state.loadType) {
                    case LoadType.PaymentModel:
                      return PaymentModes(
                        isConvenienceFeesApplied:
                        widget.isConvenienceFeesApplied,
                        listener: widget.listener,
                        paymentOptions:
                        state.paymentOptionModel?.paymentOptions,
                        order: state.paymentOptionModel?.order,
                        repository: repository,
                      );
                    default:
                      return Text(state.paymentOptionModel.toString());
                  }
                }
                return const Center(
                  child: Loader(),
                );
              },
            ),
          ),
        ));
  }
}

/// Bloc Observer For Flutter Instamojo Plugin
class SimpleBlocObserver extends BlocObserver {
  /// Bloc Observer override method for onTransition For Flutter Instamojo Plugin
  @override
  void onTransition(Bloc bloc, Transition transition) {
    if (kDebugMode) {
      print('${bloc.runtimeType} $transition');
    }
    super.onTransition(bloc, transition);
  }

  /// Bloc Observer override method for onError For Flutter Instamojo Plugin
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('${bloc.runtimeType} $error');
    }
    super.onError(bloc, error, stackTrace);
  }
}

/// Class For two types of API Calls required for Flutter Instamojo
class ApiCallType {
  final String? orderId;
  final CreateOrderBody? createOrderBody;
  final String? orderCreationUrl;
  Type callType;

  /// Class For Creating Order ID --- Flutter Instamojo
  ApiCallType.createOrder(
      {required this.createOrderBody, this.orderCreationUrl})
      : orderId = null,
        callType = Type.CREATE_ORDER;

  /// Class For Invoking Payment Directly --- Flutter Instamojo
  ApiCallType.startPayment({this.orderId})
      : createOrderBody = null,
        orderCreationUrl = null,
        callType = Type.START_PAYMENT;
}

/// Complete UI Styling Option
class StylingDetails {
  final ButtonStyling? buttonStyle;
  final ListItemStyle? listItemStyle;
  final InputFieldTextStyle? inputFieldTextStyle;
  final AlertStyle? alertStyle;
  final Color? loaderColor;

  StylingDetails(
      {this.buttonStyle,
        this.listItemStyle,
        this.loaderColor,
        this.alertStyle,
        this.inputFieldTextStyle});
}

/// InputField Styling Option
class InputFieldTextStyle {
  final TextStyle? labelTextStyle;
  final TextStyle? hintTextStyle;
  final TextStyle? textStyle;
  InputFieldTextStyle(
      {this.labelTextStyle, this.hintTextStyle, this.textStyle});
}

/// ButtonStyling Styling Option
class ButtonStyling {
  final TextStyle? buttonTextStyle;
  final Color? buttonColor;
  ButtonStyling({this.buttonTextStyle, this.buttonColor});
}

/// ListItemStyle Styling Option
class ListItemStyle {
  final TextStyle? textStyle;
  final TextStyle? subTextStyle;
  final Color? borderColor;
  ListItemStyle({this.textStyle, this.subTextStyle, this.borderColor});
}

/// AlertStyle Styling Option
class AlertStyle {
  final TextStyle? positiveButtonTextStyle;
  final TextStyle? negativeButtonTextStyle;
  final TextStyle? headingTextStyle;
  final TextStyle? messageTextStyle;

  AlertStyle(
      {this.positiveButtonTextStyle,
        this.negativeButtonTextStyle,
        this.headingTextStyle,
        this.messageTextStyle});
}

enum Type { CREATE_ORDER, START_PAYMENT }
enum Environment { TEST, PRODUCTION }
