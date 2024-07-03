import 'package:http/http.dart' as http;
export 'package:http/http.dart' show Response;

class MastodonClient {
  final String endpointUrl;
  final String accessToken;

  MastodonClient({required this.endpointUrl, required this.accessToken});

  Future<http.Response> get(String url) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    return response;
  }

  Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
      };

  Map<String, String> get headers => accessToken.isEmpty
      ? defaultHeaders
      : {
          ...defaultHeaders,
          'Authorization': 'Bearer $accessToken',
        };

  Future<http.Response> post(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    return response;
  }

  Future<http.Response> delete(String url) async {
    final response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    return response;
  }

  Future<http.Response> put(String url, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    return response;
  }
}
