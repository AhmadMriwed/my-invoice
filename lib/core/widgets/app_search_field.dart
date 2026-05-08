import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    required this.hintText,
    required this.onChanged,
    this.controller,
    super.key,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          tooltip: 'clear_search'.tr,
          onPressed: () {
            controller?.clear();
            onChanged('');
          },
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }
}
