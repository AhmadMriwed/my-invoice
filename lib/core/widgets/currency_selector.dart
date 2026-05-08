import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_text_field.dart';

class CurrencySelector extends StatefulWidget {
  const CurrencySelector({
    required this.currencyController,
    required this.symbolController,
    this.onChanged,
    super.key,
  });

  final TextEditingController currencyController;
  final TextEditingController symbolController;
  final VoidCallback? onChanged;

  @override
  State<CurrencySelector> createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector> {
  late String selected;

  static const _custom = 'custom';
  static const _options = [
    _CurrencyOption(code: 'USD', symbol: r'$'),
    _CurrencyOption(code: 'SYP', symbol: 'ل.س'),
  ];

  @override
  void initState() {
    super.initState();
    selected = _optionForCurrentValue();
  }

  @override
  void didUpdateWidget(covariant CurrencySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    selected = _optionForCurrentValue();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: selected,
          decoration: InputDecoration(labelText: 'currency'.tr),
          items: [
            for (final option in _options)
              DropdownMenuItem(
                value: option.code,
                child: Text('${option.code} (${option.symbol})'),
              ),
            DropdownMenuItem(value: _custom, child: Text('custom_currency'.tr)),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() => selected = value);
            final option = _options.firstWhereOrNull(
              (item) => item.code == value,
            );
            if (option != null) {
              widget.currencyController.text = option.code;
              widget.symbolController.text = option.symbol;
            }
            widget.onChanged?.call();
          },
        ),
        if (selected == _custom) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: widget.currencyController,
                  label: 'currency_code'.tr,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => widget.onChanged?.call(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: widget.symbolController,
                  label: 'currency_symbol'.tr,
                  onChanged: (_) => widget.onChanged?.call(),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _optionForCurrentValue() {
    final code = widget.currencyController.text.trim();
    final symbol = widget.symbolController.text.trim();
    return _options
            .firstWhereOrNull(
              (option) => option.code == code && option.symbol == symbol,
            )
            ?.code ??
        _custom;
  }
}

class _CurrencyOption {
  const _CurrencyOption({required this.code, required this.symbol});

  final String code;
  final String symbol;
}
