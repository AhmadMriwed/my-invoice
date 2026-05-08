import 'package:flutter/services.dart';

class AppInputFormatters {
  const AppInputFormatters._();

  static final digitsOnly = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
  ];

  static final decimal = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ];
}
