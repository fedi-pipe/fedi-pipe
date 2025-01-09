import 'package:fedi_pipe/components/default_layout.dart';
import 'package:fedi_pipe/components/status_collection_feed.dart';
import 'package:flutter/material.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: "Favourites",
      body: StatusCollectionFeed(
        collectionType: "favourites",
      ),
    );
  }
}
