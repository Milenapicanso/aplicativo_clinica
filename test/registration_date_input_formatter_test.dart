import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aplicativo_clinica/registro.dart';

void main() {
  test('inserts date separators while typing digits', () {
    const formatter = BirthDateInputFormatter();
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: '16112000',
        selection: TextSelection.collapsed(offset: 8),
      ),
    );

    expect(result.text, '16/11/2000');
    expect(result.selection.extentOffset, 10);
  });

  test('limits the date to eight digits', () {
    const formatter = BirthDateInputFormatter();
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: '161120001',
        selection: TextSelection.collapsed(offset: 9),
      ),
    );

    expect(result.text, '16/11/2000');
    expect(result.selection.extentOffset, 10);
  });
}
