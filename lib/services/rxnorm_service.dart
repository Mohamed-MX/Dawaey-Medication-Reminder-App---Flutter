import 'dart:convert';

import 'package:http/http.dart' as http;

class RxNormService {
  Future<List<String>> searchMedicine(String query) async {
    final String term = query.trim();

    // ما نعملش Request لو المستخدم لسه مبدأش يكتب.
    if (term.length < 2) {
      return [];
    }

    try {
      final uri = Uri.https(
        'rxnav.nlm.nih.gov',
        '/REST/approximateTerm.json',
        {
          'term': term,
          'maxEntries': '10',
          'option': '1',
        },
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode != 200) {
        throw Exception(
          'RxNorm status code: ${response.statusCode}',
        );
      }

      final dynamic decoded = jsonDecode(
        response.body,
      );

      if (decoded is! Map<String, dynamic>) {
        return [];
      }

      final dynamic candidates =
          decoded['approximateGroup']?['candidate'];

      if (candidates is! List) {
        return [];
      }

      final List<String> medicines = [];
      final List<String> rxcuisWithoutName = [];

      for (final candidate in candidates) {
        if (candidate is! Map) {
          continue;
        }

        final String name =
            (candidate['name'] ?? '')
                .toString()
                .trim();

        // لو الـAPI رجع الاسم مباشرة.
        if (name.isNotEmpty) {
          if (!medicines.contains(name)) {
            medicines.add(name);
          }

          continue;
        }

        // لو رجع RxCUI فقط، نجيب الاسم منه.
        final String rxcui =
            (candidate['rxcui'] ?? '')
                .toString()
                .trim();

        if (rxcui.isNotEmpty &&
            !rxcuisWithoutName.contains(rxcui)) {
          rxcuisWithoutName.add(rxcui);
        }
      }

      // نجيب أسماء النتائج اللي رجعت RxCUI من غير اسم.
      for (final rxcui in rxcuisWithoutName.take(8)) {
        final String? name =
            await _getMedicineName(rxcui);

        if (name != null &&
            name.isNotEmpty &&
            !medicines.contains(name)) {
          medicines.add(name);
        }

        if (medicines.length >= 8) {
          break;
        }
      }

      return medicines.take(8).toList();
    } catch (e) {
      // نخلي الـScreen هي اللي تعرض رسالة الخطأ.
      rethrow;
    }
  }

  Future<String?> _getMedicineName(
    String rxcui,
  ) async {
    try {
      final uri = Uri.https(
        'rxnav.nlm.nih.gov',
        '/REST/rxcui/$rxcui/properties.json',
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 8),
          );

      if (response.statusCode != 200) {
        return null;
      }

      final dynamic decoded = jsonDecode(
        response.body,
      );

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final String name =
          (decoded['properties']?['name'] ?? '')
              .toString()
              .trim();

      if (name.isEmpty) {
        return null;
      }

      return name;
    } catch (_) {
      return null;
    }
  }
}