import 'dart:convert';

import 'package:fedi_pipe/components/html_renderer.dart';
import 'package:fedi_pipe/extensions/string.dart';
import 'package:fedi_pipe/models/mastodon_notification.dart';
import 'package:fedi_pipe/utils/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:popover/popover.dart';
import 'package:url_launcher/url_launcher.dart';

class MastodonNotificationCard extends StatefulWidget {
  const MastodonNotificationCard({super.key, required this.notification});

  final MastodonNotificationModel notification;

  @override
  State<MastodonNotificationCard> createState() => _MastodonNotificationCardState();
}

class _MastodonNotificationCardState extends State<MastodonNotificationCard> {
  @override
  void initState() {
    super.initState();
  }

  Widget renderIcon() {
    IconData icon;
    switch (widget.notification.type) {
      case "follow":
        icon = Icons.person_add;
        break;
      case "favourite":
        icon = Icons.favorite;
        break;
      case "mention":
        icon = Icons.alternate_email;
        break;
      case "reblog":
        icon = Icons.repeat;
        break;
      default:
        icon = Icons.notifications;
        break;
    }

    return Icon(icon, size: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          renderIcon(),
          SizedBox(width: 4),
          Text(widget.notification.type.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Text("from "),
          Text("@${widget.notification.account.username}", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      if (widget.notification.status != null) Text(widget.notification.status!.content),
    ]);
  }
}
