import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamojo/bloc/instamojo_bloc.dart';
import 'package:instamojo/bloc/instamojo_event.dart';
import 'package:instamojo/bloc/instamojo_state.dart';
import 'package:instamojo/controllers/instamojo_controller.dart';
import 'package:instamojo/models/payment_option_model.dart';
import 'package:instamojo/repositories/instamojo_repository.dart';
import 'package:instamojo/widgets/trust_logo.dart';

import '../../utils.dart';
import '../browser.dart';
import '../loader.dart';
import 'app_bar_search.dart';

class NetBanking extends StatefulWidget {
  final String? title;
  final NetbankingOptions? netBankingOptions;
  final String? amount;
  final InstamojoRepository? repository;
  final InstamojoPaymentStatusListener? listener;

  const NetBanking(
      {Key? key,
      this.title,
      this.netBankingOptions,
      this.amount,
      this.repository,
      this.listener})
      : super(key: key);

  @override
  _NetBankingState createState() => _NetBankingState();
}

class _NetBankingState extends State<NetBanking> {
  TextEditingController? _filter;
  AppBarSearch? appbar;
  List? filteredNames;
  BuildContext? _buildContext;

  _NetBankingState() {
    filteredNames = [];
    _filter = TextEditingController();
  }
  @override
  void initState() {
    super.initState();

    appbar = AppBarSearch(
        state: this,
        controller: _filter,
        onSubmitted: (value) {
          BlocProvider.of<InstamojoBloc>(_buildContext!)
              .add(SearchBankEvent(banks: widget.netBankingOptions?.choices));
        });
    _filter?.addListener(() {
      if (_filter!.text.isNotEmpty) {
        BlocProvider.of<InstamojoBloc>(_buildContext!).add(SearchBankEvent(
            banks: widget.netBankingOptions?.choices, query: _filter?.text));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: appbar?.onTitle(Text(widget.title as String)),
          actions: [
            appbar!.searchIcon,
          ]),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    return BlocProvider(
      create: (context) => InstamojoBloc(repository: widget.repository),
      child: BlocBuilder<InstamojoBloc, InstamojoState>(
        builder: (context, state) {
          _buildContext = context;
          if (state is InstamojoLoaded) {
            switch (state.loadType) {
              case LoadType.SearchBank:
                return ListView.builder(
                  itemCount: state.banks!.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < state.banks!.length) {
                      return InkWell(
                        child: Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: stylingDetails.listItemStyle!
                                          .borderColor as Color))),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(state.banks![index].name as String,
                              style: stylingDetails.listItemStyle?.textStyle),
                        ),
                        onTap: () {
                          String dataPosted = state.banks![index].id as String;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (ctx) => Browser(
                                        listener: widget.listener,
                                        url: widget
                                            .netBankingOptions?.submissionUrl,
                                        postData: "bank_code=" + dataPosted,
                                      )));
                        },
                      );
                    } else {
                      return const TrustLogo();
                    }
                  },
                );

              default:
                return const Text("");
            }
          } else if (state is InstamojoEmpty) {
            BlocProvider.of<InstamojoBloc>(context)
                .add(SearchBankEvent(banks: widget.netBankingOptions?.choices));
          }
          return const Center(
            child: Loader(),
          );
        },
      ),
    );
  }
}
