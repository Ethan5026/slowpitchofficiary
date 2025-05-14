import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({super.key, this.onPressed, required this.text});

  final VoidCallback? onPressed;
  final Widget text;

  @override
  Widget build(BuildContext context) {
    return Material(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        elevation: 10,
        child: TextButton(
            onPressed: onPressed,
            // ignore: sort_child_properties_last
            child: text,
            style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.white))));
  }
}
