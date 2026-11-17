import 'package:flutter_test/flutter_test.dart';

import 'package:aplicativo_clinica/search_results_screen.dart';

void main() {
  test('empty search returns no results without a database request', () async {
    final response = await searchCatalog('   ');

    expect(response.type, SearchResultType.none);
    expect(response.professionals, isEmpty);
    expect(response.exams, isEmpty);
  });
}
