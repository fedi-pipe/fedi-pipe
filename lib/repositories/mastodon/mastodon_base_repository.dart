import 'package:fedi_pipe/utils/mastodon_client.dart';

typedef Client = MastodonBaseRepository;

class MastodonBaseRepository {
  final MastodonClient? client;
  static String endpointUrl = 'https://social.silicon.moe';
  static String accessToken = 'xlqcUs_StCuiByXxYa20M2zpjxmGbWG4TL7sKdrXikU';

  static MastodonBaseRepository? _instance;

  MastodonBaseRepository({this.client});

  static MastodonClient get instance {
    if (_instance == null) {
      _instance = MastodonBaseRepository(client: MastodonClient(endpointUrl: endpointUrl, accessToken: accessToken));
    }

    return _instance!.client!;
  }

  static Future<Response> get(String path) async {
    final url = instance.endpointUrl + path;
    return await instance.get(url);
  }

  static Future<Response> post(String path, Map<String, dynamic> body) async {
    final url = instance.endpointUrl + path;
    return await instance.post(url, body);
  }

  static Future<Response> delete(String path) async {
    final url = instance.endpointUrl + path;
    return await instance.delete(url);
  }

  static Future<Response> put(String path, Map<String, dynamic> body) async {
    final url = instance.endpointUrl + path;
    return await instance.put(url, body);
  }
}
