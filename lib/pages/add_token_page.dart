import 'dart:convert';

import 'package:fedi_pipe/repositories/persistent/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final SCOPES = 'read write follow push';

Map<String, String> defaultHeaders = {
  'Content-Type': 'application/json',
};

Future<Map<String, dynamic>> verifyCredentialsForApp(String instanceUrl, String accessToken) async {
  final url = 'https://' + instanceUrl + '/api/v1/apps/verify_credentials';
  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + accessToken,
  };
  final response = await http.get(Uri.parse(url), headers: headers);
  final result = await jsonDecode(response.body);
  return result;
}

Future<Map<String, dynamic>> verifyCredentialsForAccount(String instanceUrl, String accessToken) async {
  final url = 'https://' + instanceUrl + '/api/v1/accounts/verify_credentials';
  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + accessToken,
  };
  final response = await http.get(Uri.parse(url), headers: headers);
  final result = await jsonDecode(response.body);
  return result;
}

//const getAuthorizationURL = async ({ instanceURL, client_id }) => {
//  const authorizationParams = new URLSearchParams({
//    client_id,
//    scope: SCOPES,
//    redirect_uri: location.origin + location.pathname,
//    // redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
//    response_type: 'code',
//  });
//  const authorizationURL = `https://${instanceURL}/oauth/authorize?${authorizationParams.toString()}`;
//  return authorizationURL;
//}
//
//const instanceURL = 'pixelfed.social';
//
//const tryLogin = async (event: Event) => {
//  const { client_id, client_secret, vapid_key } = await authLogin(event);
//  console.log({ client_id, client_secret, vapid_key });
//
//  if (client_id && client_secret) {
//    sessionStorage.setItem('clientID', client_id);
//    sessionStorage.setItem('clientSecret', client_secret);
//    sessionStorage.setItem('vapidKey', vapid_key);
//
//    location.href = await getAuthorizationURL({
//      instanceURL,
//      client_id,
//    });
//  } else {
//    alert('Failed to register application');
//  }
//}
//
//const authLogin = async (event: Event) => {
//  const registrationParams = new URLSearchParams({
//    client_name: 'QuinJet',
//    redirect_uris: location.origin + location.pathname,
//    scopes: SCOPES,
//    website: "https://quinjet.vercel.app",
//  });
//
//  const registrationResponse = await fetch(
//    `https://${instanceURL}/api/v1/apps`,
//    {
//      method: 'POST',
//      headers: {
//        'Content-Type': 'application/x-www-form-urlencoded',
//      },
//      body: registrationParams.toString(),
//    },
//  );
//  const registrationJSON = await registrationResponse.json();
//  return registrationJSON;
//}

class AddTokenPage extends StatelessWidget {
  final TextEditingController _instanceController = TextEditingController();
  final TextEditingController _accessTokenController = TextEditingController();

  AddTokenPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add Token')),
        body: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _instanceController,
                decoration: InputDecoration(
                  hintText: 'Instance',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final instanceUrl = _instanceController.text;

                final registrationParams = {
                  'client_name': 'FediPipe',
                  'redirect_uris': 'fedi-pipe://fedi-pipe.github.io/oauth',
                  'scopes': SCOPES,
                  'website': 'https://fedi-pipe.github.io',
                };

                final registrationResponse = await http.post(
                  Uri.parse('https://' + instanceUrl + '/api/v1/apps'),
                  headers: defaultHeaders,
                  body: jsonEncode(registrationParams),
                );

                print(registrationResponse);

                final registrationJSON = jsonDecode(registrationResponse.body);

                print(registrationResponse.headers);

                print(registrationJSON);

                final client_id = registrationJSON['client_id'];
                final client_secret = registrationJSON['client_secret'];
                final vapid_key = registrationJSON['vapid_key'];

                final secureStorage = FlutterSecureStorage();
                await secureStorage.write(key: 'INSTANCE_URL', value: instanceUrl);
                await secureStorage.write(key: 'CLIENT_ID', value: client_id);
                await secureStorage.write(key: 'CLIENT_SECRET', value: client_secret);

                if (client_id != null && client_secret != null) {
                  final authorizationParams = {
                    'client_id': client_id,
                    'scope': SCOPES,
                    'redirect_uri': "fedi-pipe://fedi-pipe.github.io/oauth",
                    'response_type': 'code',
                  };

                  // redirecting to /oauth doesn't work
                  final authorizationURL =
                      'https://' + instanceUrl + '/oauth/authorize?' + Uri(queryParameters: authorizationParams).query;
                  final url = Uri.parse(authorizationURL);

                  launchUrl(url);
                }
              },
              child: Text('Login'),
            ),
          ],
        )));
  }
}
