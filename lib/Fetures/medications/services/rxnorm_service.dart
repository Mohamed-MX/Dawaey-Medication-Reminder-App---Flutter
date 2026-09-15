import 'dart:convert';
import 'package:http/http.dart' as http;

class RxNormService {
  static const String _baseUrl = 'https://rxnav.nlm.nih.gov/REST';

  Future<List<String>> searchMedicine(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse('$_baseUrl/approximateTerm.json?term=${Uri.encodeComponent(query)}&maxEntries=5');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final approximateGroup = data['approximateGroup'];
        
        if (approximateGroup != null && approximateGroup['candidate'] != null) {
          final candidates = approximateGroup['candidate'] as List;
          final List<String> suggestions = [];
          
          for (var candidate in candidates) {
            final name = candidate['name'];
            if (name != null && name is String && name.isNotEmpty) {
              // Deduplicate ignoring case
              if (!suggestions.any((s) => s.toLowerCase() == name.toLowerCase())) {
                suggestions.add(name);
              }
            }
          }
          return suggestions;
        }
      }
      return [];
    } catch (e) {
      // Return empty on error to prevent app crash
      return [];
    }
  }
}
