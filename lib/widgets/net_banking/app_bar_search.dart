import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppBarSearch {
  AppBarSearch({
    @required this.state,
    this.title,
    this.hintText = "search...",
    this.onPressed,
    this.controller,
    this.onSubmitted,
    this.onEditingComplete,
  }) {
    title ??= const Text("search...");

    _hintText = hintText;

    _onPressed = onPressed ?? _pressedFunc;

    _appBarTitle = GestureDetector(
      child: title,
      onTap: _onPressed,
    );

    // title is now a GestureDetector widget.
    title = _appBarTitle;

    _onSubmitted = onSubmitted;

    _onEditingComplete = onEditingComplete;

    _icon = const Icon(Icons.search);

    _textController = controller ?? TextEditingController();

    // Flag indicating user tapped to initiate search.
    _wasPressed = false;
  }
  final State? state;
  Widget? title;
  final String? hintText;
  final VoidCallback? onPressed;
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;

  Widget? _appBarTitle;
  String? _hintText;
  VoidCallback? _onPressed;
  TextEditingController? _textController;
  ValueChanged<String>? _onSubmitted;
  VoidCallback? _onEditingComplete;

  Icon? _icon;
  bool? _wasPressed;

  IconButton get searchIcon => IconButton(
        icon: _icon as Widget,
        onPressed: _onPressed,
      );

  Widget? onTitle(Widget title) {
    // title already defined.
    if (_wasPressed!) return this.title;

    if (title is! GestureDetector) {
      _appBarTitle = GestureDetector(
        child: title,
        onTap: _onPressed,
      );
    }
    return _appBarTitle;
  }

  IconButton onSearchIcon({
    String? hintText,
    TextEditingController? controller,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
  }) {
    if (hintText != null) _hintText = hintText;
    if (controller != null) _textController = controller;
    if (onSubmitted != null) _onSubmitted = onSubmitted;
    if (onEditingComplete != null) _onEditingComplete = onEditingComplete;
    return searchIcon;
  }

  void _pressedFunc() {
    _wasPressed = true;
    if (_icon!.icon == Icons.search) {
      _icon = const Icon(Icons.close);
      title = TextField(
        controller: _textController,
        textInputAction: TextInputAction.done,
        onSubmitted: _submitFunc,
        onEditingComplete: _onEditingComplete,
        autofocus: true,
        decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
            filled: true,
            hintText: _hintText,
            hintStyle: const TextStyle(fontSize: 18)),
      );
      SystemChannels.textInput.invokeMethod('TextInput.show');
    } else {
      _icon = const Icon(Icons.search);
      title = _appBarTitle;
      _textController!.clear();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      if (_onSubmitted != null) {
        _onSubmitted!("");
      } else if (onSubmitted != null) {
        onSubmitted!("");
      }
    }
    // Display the change in the app's title
    // ignore: invalid_use_of_protected_member
    state?.setState(() {});
  }

  void _submitFunc(String value) {
    _pressedFunc();
    if (_onSubmitted != null) {
      _onSubmitted!(value);
    } else if (onSubmitted != null) {
      onSubmitted!(value);
    }
  }
}
