import 'package:flutter/material.dart';

class MyButtom extends StatelessWidget {
  final Function onPressed;
  final Icon icone;
  final Text texto;

  const MyButtom(
      {super.key,
      required this.onPressed,
      required this.icone,
      required this.texto});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => onPressed,
      icon: icone,
      label: texto,
    );
  }
}
