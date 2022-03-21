import 'package:flutter/material.dart';

import '../utils.dart';

class Loader extends StatefulWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: const Duration(milliseconds: 500),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildContainer(double radius) {
      return Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: stylingDetails.loaderColor
                  ?.withOpacity(1 - _controller.value) ??
              Theme.of(context).primaryColor.withOpacity(1 - _controller.value),
        ),
      );
    }

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
}
