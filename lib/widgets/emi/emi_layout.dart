import 'package:flutter/material.dart';
import 'package:instamojo/controllers/instamojo_controller.dart';
import 'package:instamojo/models/payment_option_model.dart';
import 'package:instamojo/models/populate_card_request.dart';
import 'package:instamojo/repositories/respositories.dart';
import 'package:instamojo/widgets/card/card_layout.dart';
import 'package:instamojo/widgets/emi/emi_utils.dart';
import 'package:instamojo/widgets/trust_logo.dart';

import '../../utils.dart';

class EmiLayout extends StatefulWidget {
  final String? title;
  final Options? emiOptions;
  final String? amount;
  final InstamojoRepository? repository;
  final InstamojoPaymentStatusListener? listener;

  const EmiLayout(
      {Key? key,
      this.title,
      this.emiOptions,
      this.amount,
      this.repository,
      this.listener})
      : super(key: key);
  @override
  _EmiLayoutState createState() => _EmiLayoutState();
}

class _EmiLayoutState extends State<EmiLayout> {
  late List<DropdownMenuItem<EmiList>> _bankList;
  late EmiList _selectedBank;

  @override
  void initState() {
    _bankList = buildDropDownMenuItems(widget.emiOptions!.emiList!);
    _selectedBank = _bankList[0].value!;
    super.initState();
  }

  List<DropdownMenuItem<EmiList>> buildDropDownMenuItems(
      List<EmiList> bankList) {
    List<DropdownMenuItem<EmiList>> items = [];
    for (EmiList bank in bankList) {
      items.add(DropdownMenuItem(
        value: bank,
        child: Text(
          bank.bankName as String,
          style: stylingDetails.listItemStyle?.textStyle,
        ),
      ));
    }
    return items;
  }

  onChangedDropDownItem(EmiList? selectedBank) {
    setState(() {
      _selectedBank = selectedBank!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        widget.title as String,
      )),
      body: SingleChildScrollView(
          child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "Select your credit card provider",
              style: stylingDetails.listItemStyle?.subTextStyle,
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: stylingDetails.listItemStyle?.borderColor
                        ?.withOpacity(0.1),
                    border: Border.all(
                      color: stylingDetails.listItemStyle?.borderColor as Color,
                    ),
                    borderRadius: BorderRadius.circular(2.0)),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton(
                  items: _bankList,
                  value: _selectedBank,
                  onChanged: onChangedDropDownItem,
                  isExpanded: true,
                  underline: Container(),
                )),
            const SizedBox(
              height: 16,
            ),
            Text("Select an EMI option",
                style: stylingDetails.listItemStyle?.textStyle),
            const SizedBox(
              height: 8,
            ),
            Column(
              children: _selectedBank.rates!.map((value) {
                double emiAmount = getEmiAmount(widget.amount as String,
                    value.interest.toString(), value.tenure as int);
                String emiAmountString = "₹" +
                    emiAmount.toString() +
                    " x " +
                    value.tenure.toString() +
                    " Months";
                String finalAmountString = "Total ₹" +
                    getTotalAmount(emiAmount, value.tenure as int).toString() +
                    " @ " +
                    value.interest.toString() +
                    "% pa";

                return InkWell(
                  child: Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0XFFCCD1D9),
                          ),
                          borderRadius: BorderRadius.circular(2.0)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                Text(
                                  emiAmountString,
                                  style:
                                      stylingDetails.listItemStyle!.textStyle,
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  finalAmountString,
                                  style: stylingDetails
                                      .listItemStyle!.subTextStyle,
                                )
                              ])),
                          Icon(
                            Icons.chevron_right,
                            color: stylingDetails.listItemStyle!.borderColor,
                          )
                        ],
                      )),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => CardLayout(
                                  amount: widget.amount,
                                  title: widget.title,
                                  cardOptions: widget.emiOptions,
                                  listener: widget.listener,
                                  repository: widget.repository,
                                  emiOptions: EmiOptions(
                                      emiTenure: value.tenure,
                                      emibankCode: _selectedBank.bankCode),
                                )));
                  },
                );
              }).toList(),
            ),
            const TrustLogo()
          ],
        ),
      )),
    );
  }
}
