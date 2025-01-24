import 'package:fedi_pipe/components/html_renderer.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final MastodonAccountModel account;
  const ProfilePage({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(account.displayName!),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              account.header!,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Transform.translate(
                        offset: Offset(0, -50),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(account.avatar!),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, -60),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Theme.of(context).primaryColor,
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Follow",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor))),
                            )
                          ]),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 40),
                          Row(
                            children: [
                              Expanded(
                                child: Text(account.displayName!,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          Text("@${account.acct!}",
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  HtmlRenderer(html: account.note!)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
