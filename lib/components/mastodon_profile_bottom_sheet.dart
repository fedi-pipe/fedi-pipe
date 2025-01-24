import 'package:fedi_pipe/components/html_renderer.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/pages/profile_page.dart';
import 'package:fedi_pipe/repositories/mastodon/account_repository.dart';
import 'package:flutter/material.dart';

void showMastodonProfileBottomSheet(BuildContext context, String acct) {
  MastodonAccountRepository.lookUpAccount(acct).then((account) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return MastodonProfileBottomSheet(account: account);
      },
    );
  });
}

class MastodonProfileBottomSheet extends StatelessWidget {
  final MastodonAccountModel account;
  const MastodonProfileBottomSheet({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage(account: account)));
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(account.avatar!),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.displayName!,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                      account.acct!,
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          HtmlRenderer(html: account.note!),
          SizedBox(height: 16),
        ]),
      ),
    );
  }
}
