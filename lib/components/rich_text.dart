import 'package:flutter/material.dart';

class CustomRichText extends StatelessWidget {
  final String noteTitle;
  final String firstText;
  final String lastText;
  final String? optionalText; // does not need to be passed in

  const CustomRichText({
    super.key, 
    required this.noteTitle,
    required this.firstText,
    required this.lastText,
    this.optionalText, // not required
  });
  @override
  Widget build(BuildContext context) {
    final List<TextSpan> children = [
      TextSpan(
        text: firstText,
        style: DefaultTextStyle.of(context).style,
      ),
      TextSpan(
        text: noteTitle,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // title of note is bold in dialog box
      ),
      TextSpan(
        text: lastText,
        style: DefaultTextStyle.of(context).style,
      ),
    ];

    if (optionalText != null) { // if additional text received, append to children list as own span
      children.add(TextSpan(
        text: optionalText,
        style: const TextStyle(color: Colors.red), // relevant for confirm sync as per figma
      ));
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: children),
    );
  }
}
