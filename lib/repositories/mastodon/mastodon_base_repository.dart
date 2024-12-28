import 'package:fedi_pipe/utils/mastodon_client.dart';

typedef Client = MastodonBaseRepository;

class MastodonBaseRepository {
  final MastodonClient? client;

  static MastodonBaseRepository? _instance;

  MastodonBaseRepository({this.client});

  static MastodonClient get instance {
    if (_instance == null) {
      _instance = MastodonBaseRepository(client: MastodonClient());
    }

    return _instance!.client!;
  }

  static void resetConnection() {
    _instance = null;
  }

  static Future<Response> get(String path, {Map<String, String>? queryParameters, Map<String, String>? headers}) async {
    final baseUrl = await instance.getEndpointUrl();
    final url = baseUrl! + path;
    return await instance.get(url, queryParameters: queryParameters, additionalHeaders: headers);
  }

  static Future<Response> post(String path, Map<String, dynamic> body) async {
    final baseUrl = await instance.getEndpointUrl();

    final url = baseUrl! + path;
    return await instance.post(url, body);
  }

  static Future<Response> delete(String path) async {
    final baseUrl = await instance.getEndpointUrl();
    final url = baseUrl! + path;
    return await instance.delete(url);
  }

  static Future<Response> put(String path, Map<String, dynamic> body) async {
    final baseUrl = await instance.getEndpointUrl();
    final url = baseUrl! + path;
    return await instance.put(url, body);
  }
}
