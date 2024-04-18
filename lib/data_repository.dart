import 'package:http/http.dart' as http;

class DataRepository {
  final String apiUrl;

  DataRepository({required this.apiUrl});

  Future<String> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
