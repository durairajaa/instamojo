import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instamojo/instamojo.dart';

import 'model/data_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        color: Colors.black,
        routes: const {},
        title: 'Styli',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle.light),
            primarySwatch: Colors.pink,
            canvasColor: Colors.white,
            backgroundColor: Colors.white,
            brightness: Brightness.light,
            cupertinoOverrideTheme: const CupertinoThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              barBackgroundColor: Colors.white,
              primaryColor: Colors.amber,
            )),
        darkTheme: ThemeData(
            appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle.dark),
            primarySwatch: Colors.amber,
            canvasColor: Colors.black,
            brightness: Brightness.dark,
            cupertinoOverrideTheme: const CupertinoThemeData(
              primaryColor: Colors.amber,
            )),
        home: const PaymentScreen());
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  String _paymentResponse = 'Unknown';
  late bool isLive, apiCalled;
  final _formKey = GlobalKey<FormState>();
  final _data = DataModel();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    isLive = false;
    apiCalled = false;
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: const Duration(milliseconds: 500),
    )..repeat();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  startInstamojo() async {
    dynamic result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => InstamojoScreen(
                  isLive: _data.isLive,
                  body: CreateOrderBody(
                      buyerName: _data.name,
                      buyerEmail: _data.email,
                      buyerPhone: _data.number,
                      amount: _data.amount,
                      description: _data.description),
                  orderCreationUrl:
                      "https://sample-sdk-server.instamojo.com/order", // The sample server of instamojo to create order id.
                )));

    setState(() {
      _paymentResponse = result.toString();
    });
  }

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
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Builder(
                  builder: (context) => Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              initialValue: "Test Payments",
                              keyboardType: TextInputType.text,
                              decoration:
                                  const InputDecoration(labelText: 'Name'),
                              // ignore: missing_return
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter the name';
                                }
                                return null;
                              },
                              onSaved: (val) =>
                                  setState(() => _data.name = val!),
                            ),
                            TextFormField(
                                initialValue: "test@test.com",
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                    labelText: 'Email Id'),
                                // ignore: missing_return
                                validator: validateEmail,
                                onSaved: (val) =>
                                    setState(() => _data.email = val!)),
                            TextFormField(
                                initialValue: "1234567890",
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                decoration: const InputDecoration(
                                    labelText: 'Mobile Number'),
                                // ignore: missing_return
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter the phone number.';
                                  } else if (value.length < 10) {
                                    return "Please enter a valid phone number";
                                  }
                                  return null;
                                },
                                onSaved: (val) =>
                                    setState(() => _data.number = val!)),
                            TextFormField(
                                initialValue: "33",
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                decoration:
                                    const InputDecoration(labelText: 'Amount'),
                                // ignore: missing_return
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter the amount.';
                                  }
                                  return null;
                                },
                                onSaved: (val) =>
                                    setState(() => _data.amount = val!)),
                            TextFormField(
                                initialValue: "test description",
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                    labelText: 'Description'),
                                onSaved: (val) =>
                                    setState(() => _data.description = val!)),
                            SwitchListTile(
                                title: Text(_data.isLive
                                    ? 'Live Account'
                                    : 'Test Account'),
                                value: _data.isLive,
                                onChanged: (bool val) =>
                                    setState(() => _data.isLive = val)),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                  onPressed: () {
                                    final form = _formKey.currentState;
                                    if (form!.validate()) {
                                      form.save();
                                      startInstamojo();
                                    }
                                  },
                                  child: apiCalled
                                      ? animation()
                                      : const Text('Make Payment')),
                            ),
                          ])))),
          const SizedBox(
            height: 20,
          ),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("Response: $_paymentResponse")),
          const SizedBox(
            height: 30,
          ),
        ],
      )),
    );
  }

  Widget animation() {
    return AnimatedBuilder(
      animation:
          CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildContainer(15 * _controller.value),
            _buildContainer(20 * _controller.value),
            _buildContainer(25 * _controller.value),
            _buildContainer(30 * _controller.value),
            _buildContainer(35 * _controller.value),
          ],
        );
      },
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            Theme.of(context).primaryColor.withOpacity(1 - _controller.value),
      ),
    );
  }

  String? validateEmail(String? value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern as String);
    if (!regex.hasMatch(value!)) {
      return 'Enter Valid Email';
    } else {
      return null;
    }
  }
}

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
            child: Instamojo(
          isConvenienceFeesApplied: false,
          listener: this,
          environment:
              widget.isLive! ? Environment.PRODUCTION : Environment.TEST,
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
                  subTextStyle:
                      const TextStyle(color: Colors.grey, fontSize: 14)),
              loaderColor: Colors.amber,
              inputFieldTextStyle: InputFieldTextStyle(
                  textStyle: const TextStyle(color: Colors.black, fontSize: 18),
                  hintTextStyle:
                      const TextStyle(color: Colors.grey, fontSize: 14),
                  labelTextStyle:
                      const TextStyle(color: Colors.grey, fontSize: 14)),
              alertStyle: AlertStyle(
                headingTextStyle:
                    const TextStyle(color: Colors.black, fontSize: 14),
                messageTextStyle:
                    const TextStyle(color: Colors.black, fontSize: 12),
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

print(String message) {
  debugPrint(message);
}
