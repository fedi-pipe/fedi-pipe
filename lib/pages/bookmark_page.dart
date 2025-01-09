import 'package:fedi_pipe/components/default_layout.dart';
import 'package:fedi_pipe/components/status_collection_feed.dart';
import 'package:flutter/material.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: "Bookmarks",
      body: StatusCollectionFeed(
        collectionType: "bookmarks",
      ),
    );
  }
}
