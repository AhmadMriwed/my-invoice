import 'package:flutter/material.dart';

class CustomerInfoTile extends StatelessWidget {
  const CustomerInfoTile({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon == null ? null : Icon(icon),
      title: Text(label),
      subtitle: Text(value.isEmpty ? '-' : value),
      contentPadding: EdgeInsets.zero,
    );
  }
}
