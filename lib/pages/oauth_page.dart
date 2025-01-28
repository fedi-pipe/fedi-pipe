import 'dart:convert';

import 'package:fedi_pipe/repositories/persistent/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//const code = decodeURIComponent(
//  (window.location.search.match(/code=([^&]+)/) || [, ''])[1],
//);
//
//const DEFAULT_INSTANCE = 'pixelfed.social';
//const apis = {};
//
//const accountApis = {};
//window.__ACCOUNT_APIS__ = accountApis;
//
//const initClient = async ({ instance, accessToken }) => {
//  if (/^https?:\/\//.test(instance)) {
//    instance = instance
//      .replace(/^https?:\/\//, '')
//      .replace(/\/+$/, '')
//      .toLowerCase();
//  }
//  const url = instance ? `https://${instance}` : `https://${DEFAULT_INSTANCE}`;
//
//
//  const masto = createRestAPIClient({
//    url,
//    accessToken, // Can be null
//    timeout: 30_000, // Unfortunatly this is global instead of per-request
//  });
//
//  const client = {
//    masto,
//    instance,
//    accessToken,
//  };
//  apis[instance] = client;
//  if (!accountApis[instance]) accountApis[instance] = {};
//  if (accessToken) accountApis[instance][accessToken] = client;
//
//  return client;
//}
//
//const getAccessToken = async ({
//  instanceURL,
//  client_id,
//  client_secret,
//  code,
//}) => {
//  const params = new URLSearchParams({
//    client_id,
//    client_secret,
//    redirect_uri: location.origin + location.pathname,
//    grant_type: 'authorization_code',
//    code,
//    scope: SCOPES,
//  });
//  const tokenResponse = await fetch(`https://${instanceURL}/oauth/token`, {
//    method: 'POST',
//    headers: {
//      'Content-Type': 'application/x-www-form-urlencoded',
//    },
//    body: params.toString(),
//  });
//  const tokenJSON = await tokenResponse.json();
//  console.log({ tokenJSON });
//  return tokenJSON;
//}
//
//if (code) {
//  console.log({ code });
//  // Clear the code from the URL
//  window.history.replaceState(
//    {},
//    document.title,
//    window.location.pathname || '/',
//  );
//
//  const clientID = sessionStorage.getItem('clientID');
//  const clientSecret = sessionStorage.getItem('clientSecret');
//  const vapidKey = sessionStorage.getItem('vapidKey');
//
//  const instanceURL = 'pixelfed.social';
//  const { access_token: accessToken } = await getAccessToken({
//    instanceURL,
//    client_id: clientID,
//    client_secret: clientSecret,
//    code,
//  });
//
//  const client = initClient({ instance: instanceURL, accessToken });
//  sessionStorage.setItem('accessToken', accessToken);
//}
//"
//if (sessionStorage.getItem('accessToken') === null && window.location.pathname !== '/login') {
//  window.location.href = '/login';
//}
//

class OAuthPage extends StatefulWidget {
  final String? code;
  const OAuthPage({super.key, required this.code});

  @override
  State<OAuthPage> createState() => _OAuthPageState();
}

class _OAuthPageState extends State<OAuthPage> {
  @override
  void initState() {
    super.initState();

    initClient();
  }

  Future<void> initClient() async {
    final secureStorage = FlutterSecureStorage();
    final instanceUrl = await secureStorage.read(key: 'INSTANCE_URL');
    final clientId = await secureStorage.read(key: 'CLIENT_ID');
    final clientSecret = await secureStorage.read(key: 'CLIENT_SECRET');

    final tokenJSON = await _getAccessToken(
      instanceUrl: instanceUrl!,
      clientId: clientId!,
      clientSecret: clientSecret!,
      code: widget.code!,
    );

    print(tokenJSON);
    final accessToken = tokenJSON['access_token'];
    if (accessToken != null) {
      final accountJSON = await _verifyCredentialsForApp(
        instanceUrl: instanceUrl,
        accessToken: accessToken,
      );

      final repository = AuthRepository();
      await repository.saveAuth(
        instanceUrl,
        accessToken,
      );

      context.go('/');
    }
  }

  Future<Map<String, dynamic>> _verifyCredentialsForApp({
    required String instanceUrl,
    required String accessToken,
  }) async {
    final url = 'https://$instanceUrl/api/v1/apps/verify_credentials';
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final response = await http.get(Uri.parse(url), headers: headers);
    final result = await jsonDecode(response.body);
    return result;
  }

  Future<Map<String, dynamic>> _getAccessToken({
    required String instanceUrl,
    required String clientId,
    required String clientSecret,
    required String code,
  }) async {
    final params = {
      'client_id': clientId,
      'client_secret': clientSecret,
      'redirect_uri': 'fedi-pipe://fedi-pipe.github.io/oauth',
      'grant_type': 'authorization_code',
      'code': code,
      'scope': 'read write follow push',
    };
    final tokenResponse = await http.post(
      Uri.parse('https://$instanceUrl/oauth/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: params,
    );
    final tokenJSON = await jsonDecode(tokenResponse.body);
    return tokenJSON;
  }

  @override
  Widget build(BuildContext context) {
    print("Hello Oauth");
    print(widget.code);
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
