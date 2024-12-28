import 'dart:convert';

import 'package:fedi_pipe/repositories/persistent/auth_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _accessTokenController,
                decoration: InputDecoration(
                  hintText: 'Access Token',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final instanceUrl = _instanceController.text;
                final accessToken = _accessTokenController.text;

                final result = await verifyCredentialsForApp(instanceUrl, accessToken);
                final appName = result['name'];

                if (appName != null) {
                  final json = await verifyCredentialsForAccount(instanceUrl, accessToken);
                  final displayName = json['display_name'];
                  final username = json['username'];
                  final source = json['source'] ?? {};
                  //final description = source['note'] ?? "";

                  // ConfirmDialog
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Confirm'),
                        content: Text("Are you sure you want to login as ${username} at ${instanceUrl}?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final authRepository = AuthRepository();
                              await authRepository.saveAuth(instanceUrl, accessToken);

                              context.goNamed("home");
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: Text('Login'),
            ),
          ],
        )));
  }
}
