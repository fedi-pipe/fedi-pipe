import 'package:fedi_pipe/utils/mastodon_client.dart';

class PaginationResult<T> {
  String? previousId;
  String? nextId;
  List<T>? items;

  PaginationResult({this.previousId, this.nextId, this.items = const []});

  PaginationResult.parseLinkHeader(String linkHeader) {
    final links = linkHeader.split(', ');

    for (final link in links) {
      final parts = link.split('; ');
      final url = parts[0].substring(1, parts[0].length - 1);
      final rel = parts[1].substring(5, parts[1].length - 1);

      if (rel == 'next') {
        this.previousId = Uri.parse(url).queryParameters['max_id'];
      } else if (rel == 'prev') {
        this.nextId = Uri.parse(url).queryParameters['min_id'];
      }
    }
  }
}

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
