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
    print(["Account", json]);
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
      locked: json['locked'] ?? false,
      bot: json['bot'] ?? false,
      discoverable: json['discoverable'] ?? false,
    );
  }
}

class MediaAttachmentModel {
  final String? id;
  final String? type;
  final String? url;
  final String? previewUrl;
  final String? remoteUrl;
  final String? textUrl;
  final String? description;
  final String? blurhash;

  MediaAttachmentModel({
    required this.id,
    required this.type,
    required this.url,
    required this.previewUrl,
    required this.remoteUrl,
    required this.textUrl,
    required this.description,
    required this.blurhash,
  });

  factory MediaAttachmentModel.fromJson(Map<String, dynamic> json) {
    return MediaAttachmentModel(
      id: json['id'],
      type: json['type'],
      url: json['url'],
      previewUrl: json['preview_url'],
      remoteUrl: json['remote_url'],
      textUrl: json['text_url'],
      description: json['description'],
      blurhash: json['blurhash'],
    );
  }

  static List<MediaAttachmentModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MediaAttachmentModel.fromJson(json)).toList();
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
  final String? url;
  final String createdAt;
  final String acct;
  final String accountDisplayName;
  final String accountUsername;
  final String accountAvatarUrl;

  int reblogsCount = 0;
  int favouritesCount = 0;
  int repliesCount = 0;

  bool bookmarked = false;
  bool reblogged = false;
  bool favourited = false;

  final dynamic json;

  final MastodonStatusModel? reblog;
  final MastodonCardModel? card;
  final MastodonAccountModel account;

  List<MastodonStatusMentionModel> mentions;

  List<MediaAttachmentModel> mediaAttachments = [];

  MastodonStatusModel({
    required this.id,
    required this.content,
    required this.url,
    required this.createdAt,
    required this.acct,
    required this.accountDisplayName,
    required this.accountUsername,
    required this.accountAvatarUrl,
    required this.account,
    this.reblog,
    this.bookmarked = false,
    this.reblogged = false,
    this.favourited = false,
    this.favouritesCount = 0,
    this.reblogsCount = 0,
    this.repliesCount = 0,
    this.card,
    this.mediaAttachments = const [],
    this.mentions = const [],
    this.json,
  });

  factory MastodonStatusModel.fromJson(Map<String, dynamic> json) {
    final account = json['account'];
    final card = json['card'];
    print(json['bookmarked']);
    return MastodonStatusModel(
      id: json['id'],
      content: json['content'],
      url: json['url'],
      createdAt: json['created_at'],
      acct: account['acct'],
      bookmarked: json['bookmarked'],
      reblogged: json['reblogged'],
      favourited: json['favourited'],
      reblog: json['reblog'] != null ? MastodonStatusModel.fromJson(json['reblog']) : null,
      favouritesCount: json['favourites_count'],
      reblogsCount: json['reblogs_count'],
      repliesCount: json['replies_count'],
      accountDisplayName: account['display_name'],
      accountUsername: account['username'],
      accountAvatarUrl: account['avatar'],
      card: card != null ? MastodonCardModel.fromJson(card) : null,
      account: MastodonAccountModel.fromJson(account),
      mentions: MastodonStatusMentionModel.fromJsonList(json['mentions']),
      mediaAttachments: MediaAttachmentModel.fromJsonList(json['media_attachments']),
      json: json,
    );
  }

  static List<MastodonStatusModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MastodonStatusModel.fromJson(json)).toList();
  }

  List<String> replyMentions() {
    return ["@${acct}", ...mentions.map((mention) => '@${mention.acct}').toList()];
  }
}

class MastodonStatusMentionModel {
  final String id;
  final String acct;
  final String username;

  MastodonStatusMentionModel({
    required this.id,
    required this.acct,
    required this.username,
  });

  factory MastodonStatusMentionModel.fromJson(Map<String, dynamic> json) {
    return MastodonStatusMentionModel(
      id: json['id'],
      acct: json['acct'],
      username: json['username'],
    );
  }

  static List<MastodonStatusMentionModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MastodonStatusMentionModel.fromJson(json)).toList();
  }
}
