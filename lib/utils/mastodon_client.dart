import 'dart:convert';

import 'package:fedi_pipe/repositories/persistent/auth_repository.dart';
import 'package:http/http.dart' as http;
export 'package:http/http.dart' show Response;

typedef HttpHeader = Map<String, String>;

class MastodonClient {
  Future<String?> getEndpointUrl() async {
    AuthRepository authRepository = AuthRepository();
    final auth = await authRepository.getAuth();

    if (auth == null) {
      return null;
    }

    return 'https://${auth.instance}';
  }

  Future<String?> getAccessToken() async {
    AuthRepository authRepository = AuthRepository();
    final auth = await authRepository.getAuth();

    if (auth == null) {
      return null;
    }

    return auth.accessToken;
  }

  Future<http.Response> get(String url, {Map<String, String>? queryParameters, HttpHeader? additionalHeaders}) async {
    final baseHeaders = await getBaseHeaders();
    final headers = {
      ...baseHeaders,
      ...?additionalHeaders,
    };
    var urlWithParams = Uri.parse(url);
    urlWithParams = urlWithParams.replace(queryParameters: queryParameters);
    final response = await http.get(urlWithParams, headers: headers);
    return response;
  }

  Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
      };

  Future<Map<String, String>> getBaseHeaders() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      return defaultHeaders;
    }

    return {
      ...defaultHeaders,
      'Authorization': 'Bearer $accessToken',
    };
  }

  Future<http.Response> post(String url, Map<String, dynamic> body, {HttpHeader? additionalHeaders}) async {
    final baseHeaders = await getBaseHeaders();
    final headers = {
      ...baseHeaders,
      ...?additionalHeaders,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    return response;
  }

  Future<http.Response> delete(String url, {HttpHeader? additionalHeaders}) async {
    final baseHeaders = await getBaseHeaders();
    final headers = {
      ...baseHeaders,
      ...?additionalHeaders,
    };
    final response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    return response;
  }

  Future<http.Response> put(String url, Map<String, dynamic> body, {HttpHeader? additionalHeaders}) async {
    final baseHeaders = await getBaseHeaders();
    final headers = {
      ...baseHeaders,
      ...?additionalHeaders,
    };
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    return response;
  }
}
