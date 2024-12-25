class MastodonAccountModel {
  final String id;
  final String username;
  final String? acct;
  final String? displayName;
  final String? note;
  final String? url;
  final String? avatar;
  final String? header;
  final int followersCount;
  final int followingCount;
  final int statusesCount;
  final bool locked;
  final bool bot;
  final bool discoverable;

  MastodonAccountModel({
    required this.id,
    required this.username,
    required this.acct,
    required this.displayName,
    required this.note,
    required this.url,
    required this.avatar,
    required this.header,
    required this.followersCount,
    required this.followingCount,
    required this.statusesCount,
    required this.locked,
    required this.bot,
    required this.discoverable,
  });

  factory MastodonAccountModel.fromJson(Map<String, dynamic> json) {
    return MastodonAccountModel(
      id: json['id'],
      username: json['username'],
      acct: json['acct'],
      displayName: json['display_name'],
      note: json['note'],
      url: json['url'],
      avatar: json['avatar'],
      header: json['header'],
      followersCount: json['followers_count'],
      followingCount: json['following_count'],
      statusesCount: json['statuses_count'],
      locked: json['locked'],
      bot: json['bot'],
      discoverable: json['discoverable'],
    );
  }
}

class MastodonCardModel {
  final String? embedUrl;
  final String? description;
  final String? html;
  final String? type;
  final int height;
  final String? url;
  final String? title;
  final String? publishedAt;
  final int width;
  final String? authorName;
  final String? langauge;
  final String? providerName;
  final String? imageDescription;
  final String? image;
  final String? authorUrl;
  final String? blurhash;
  final String? providerUrl;

  MastodonCardModel({
    required this.embedUrl,
    this.description = '',
    this.html = '',
    this.type = '',
    this.height = 0,
    this.url = '',
    this.title = '',
    this.publishedAt = '',
    this.width = 0,
    this.authorName = '',
    this.langauge = '',
    this.providerName = '',
    this.imageDescription = '',
    this.image = '',
    this.authorUrl = '',
    this.blurhash = '',
    this.providerUrl = '',
  });

  factory MastodonCardModel.fromJson(Map<String, dynamic> json) {
    return MastodonCardModel(
      embedUrl: json['embed_url'],
      description: json['description'],
      html: json['html'],
      type: json['type'],
      height: json['height'],
      url: json['url'],
      title: json['title'],
      publishedAt: json['published_at'],
      width: json['width'],
      authorName: json['author_name'],
      langauge: json['langauge'],
      providerName: json['provider_name'],
      imageDescription: json['image_description'],
      image: json['image'],
      authorUrl: json['author_url'],
      blurhash: json['blurhash'],
      providerUrl: json['provider_url'],
    );
  }
}

class MastodonStatusModel {
  final String id;
  final String content;
  final String url;
  final String createdAt;
  final String accountDisplayName;
  final String accountUsername;
  final String accountAvatarUrl;
  final MastodonCardModel? card;
  final MastodonAccountModel account;

  MastodonStatusModel({
    required this.id,
    required this.content,
    required this.url,
    required this.createdAt,
    required this.accountDisplayName,
    required this.accountUsername,
    required this.accountAvatarUrl,
    required this.account,
    this.card,
  });

  factory MastodonStatusModel.fromJson(Map<String, dynamic> json) {
    final account = json['account'];
    final card = json['card'];
    return MastodonStatusModel(
      id: json['id'],
      content: json['content'],
      url: json['url'],
      createdAt: json['created_at'],
      accountDisplayName: account['display_name'],
      accountUsername: account['username'],
      accountAvatarUrl: account['avatar'],
      card: card != null ? MastodonCardModel.fromJson(card) : null,
      account: MastodonAccountModel.fromJson(account),
    );
  }

  static List<MastodonStatusModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MastodonStatusModel.fromJson(json)).toList();
  }
}
