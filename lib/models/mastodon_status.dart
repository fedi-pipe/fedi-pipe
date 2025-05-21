// lib/models/mastodon_status.dart

// Definition for profile metadata fields
class MastodonFieldModel {
  final String name;
  final String value; // This can be HTML content
  final String? verifiedAt; // Optional: Timestamp of verification

  MastodonFieldModel({required this.name, required this.value, this.verifiedAt});

  factory MastodonFieldModel.fromJson(Map<String, dynamic> json) {
    print(json);
    return MastodonFieldModel(
      name: json['name'] as String,
      value: json['value'] as String,
      verifiedAt: json['verified_at'] as String?,
    );
  }
}

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
  final List<MastodonFieldModel> fields;

  @override
  String toString() {
    return "@${acct ?? username}";
  }

  MastodonAccountModel({
    required this.id,
    required this.username,
    this.acct, // Made optional as per some API responses
    this.displayName,
    this.note,
    this.url,
    this.avatar,
    this.header,
    required this.followersCount,
    required this.followingCount,
    required this.statusesCount,
    required this.locked,
    required this.bot,
    required this.discoverable,
    this.fields = const [],
  });

  factory MastodonAccountModel.fromJson(Map<String, dynamic> json) {
    List<MastodonFieldModel> parsedFields = const []; // Default to const empty list
    final dynamic fieldsJson = json['fields'];
    print(fieldsJson);

    if (fieldsJson is List) {
      // Check if 'fields' is a list
      parsedFields = fieldsJson
          .map((e) {
            // Ensure each element 'e' is a map before attempting to parse
            if (e is Map<String, dynamic>) {
              try {
                return MastodonFieldModel.fromJson(e);
              } catch (fieldError) {
                // Optional: Log error for individual field parsing
                // print("Error parsing a field: $fieldError for item $e");
                return null; // Return null for items that fail to parse
              }
            }
            return null; // Item in list is not a map
          })
          .whereType<MastodonFieldModel>() // Filter out any nulls from failed parsing
          .toList();
    } else if (fieldsJson != null) {
      // Optional: Log if 'fields' is present but not a list
      // print("Warning: 'fields' in JSON was not a List, but: ${fieldsJson.runtimeType}");
    }

    return MastodonAccountModel(
      id: json['id'] as String,
      username: json['username'] as String,
      acct: json['acct'] as String?,
      displayName: json['display_name'] as String?,
      note: json['note'] as String?,
      url: json['url'] as String?,
      avatar: json['avatar'] as String?,
      header: json['header'] as String?,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      statusesCount: json['statuses_count'] as int? ?? 0,
      locked: json['locked'] as bool? ?? false,
      bot: json['bot'] as bool? ?? false,
      discoverable: json['discoverable'] as bool? ?? false,
      fields: parsedFields, // Assign the robustly parsed list
    );
  }
}

class MediaAttachmentModel {
  final String? id;
  final String? type;
  final String? url;
  final String? previewUrl;
  final String? remoteUrl;
  final String? textUrl; // Was present in your original model structure context from previous turns
  final String? description;
  final String? blurhash;

  MediaAttachmentModel({
    this.id,
    this.type,
    this.url,
    this.previewUrl,
    this.remoteUrl,
    this.textUrl,
    this.description,
    this.blurhash,
  });

  factory MediaAttachmentModel.fromJson(Map<String, dynamic> json) {
    return MediaAttachmentModel(
      id: json['id'] as String?,
      type: json['type'] as String?,
      url: json['url'] as String?,
      previewUrl: json['preview_url'] as String?,
      remoteUrl: json['remote_url'] as String?,
      textUrl: json['text_url'] as String?, // Assuming this field is sometimes present
      description: json['description'] as String?,
      blurhash: json['blurhash'] as String?,
    );
  }

  static List<MediaAttachmentModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MediaAttachmentModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}

class MastodonCardModel {
  final String? embedUrl;
  final String? description;
  final String? html;
  final String? type;
  final int? height; // Made nullable based on typical API variations
  final String? url;
  final String? title;
  final String? publishedAt;
  final int? width; // Made nullable
  final String? authorName;
  final String? langauge; // Preserving original 'langauge' typo if it was in your model
  final String? providerName;
  final String? imageDescription;
  final String? image;
  final String? authorUrl;
  final String? blurhash;
  final String? providerUrl;

  MastodonCardModel({
    this.embedUrl,
    this.description = '',
    this.html = '',
    this.type = '',
    this.height = 0,
    this.url = '',
    this.title = '',
    this.publishedAt = '',
    this.width = 0,
    this.authorName = '',
    this.langauge = '', // Preserving typo
    this.providerName = '',
    this.imageDescription = '',
    this.image = '',
    this.authorUrl = '',
    this.blurhash = '',
    this.providerUrl = '',
  });

  factory MastodonCardModel.fromJson(Map<String, dynamic> json) {
    return MastodonCardModel(
      embedUrl: json['embed_url'] as String?,
      description: json['description'] as String? ?? '',
      html: json['html'] as String? ?? '',
      type: json['type'] as String? ?? '',
      height: json['height'] as int?, // Allow null
      url: json['url'] as String? ?? '',
      title: json['title'] as String? ?? '',
      publishedAt: json['published_at'] as String?,
      width: json['width'] as int?, // Allow null
      authorName: json['author_name'] as String? ?? '',
      langauge: json['langauge'] as String? ?? '', // Preserving typo from original context
      providerName: json['provider_name'] as String? ?? '',
      imageDescription: json['image_description'] as String? ?? '',
      image: json['image'] as String?,
      authorUrl: json['author_url'] as String? ?? '',
      blurhash: json['blurhash'] as String?,
      providerUrl: json['provider_url'] as String? ?? '',
    );
  }
}

class MastodonStatusModel {
  final String id;
  final String content;
  final String? url;
  final String createdAt;

  // Restored direct account fields as requested
  final String acct;
  final String accountDisplayName;
  final String accountUsername;
  final String accountAvatarUrl;

  int reblogsCount;
  int favouritesCount;
  int repliesCount;

  bool bookmarked;
  bool reblogged;
  bool favourited;

  final dynamic json; // To store the raw JSON for debugging or future use

  final MastodonStatusModel? reblog; // For reblogged statuses
  final MastodonCardModel? card; // For link previews
  final MastodonAccountModel account; // The account that authored this status

  List<MastodonStatusMentionModel> mentions;
  List<MediaAttachmentModel> mediaAttachments;

  MastodonStatusModel({
    required this.id,
    required this.content,
    this.url,
    required this.createdAt,
    required this.acct, // Restored
    required this.accountDisplayName, // Restored
    required this.accountUsername, // Restored
    required this.accountAvatarUrl, // Restored
    required this.account, // Nested account object also retained
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
    final accountJson = json['account'] as Map<String, dynamic>;
    final cardJson = json['card'] as Map<String, dynamic>?; // Card can be null

    return MastodonStatusModel(
      id: json['id'] as String,
      content: json['content'] as String,
      url: json['url'] as String?,
      createdAt: json['created_at'] as String,

      // Populating restored direct fields from accountJson
      acct: accountJson['acct'] as String? ?? accountJson['username'] as String, // Fallback for acct
      accountDisplayName: accountJson['display_name'] as String? ?? accountJson['username'] as String,
      accountUsername: accountJson['username'] as String,
      accountAvatarUrl: accountJson['avatar'] as String? ?? '', // Provide a default empty string

      account: MastodonAccountModel.fromJson(accountJson),

      reblog: json['reblog'] != null ? MastodonStatusModel.fromJson(json['reblog'] as Map<String, dynamic>) : null,
      bookmarked: json['bookmarked'] as bool? ?? false,
      reblogged: json['reblogged'] as bool? ?? false,
      favourited: json['favourited'] as bool? ?? false,
      favouritesCount: json['favourites_count'] as int? ?? 0,
      reblogsCount: json['reblogs_count'] as int? ?? 0,
      repliesCount: json['replies_count'] as int? ?? 0,
      card: cardJson != null ? MastodonCardModel.fromJson(cardJson) : null,
      mentions:
          json['mentions'] != null ? MastodonStatusMentionModel.fromJsonList(json['mentions'] as List<dynamic>) : [],
      mediaAttachments: json['media_attachments'] != null
          ? MediaAttachmentModel.fromJsonList(json['media_attachments'] as List<dynamic>)
          : [],
      json: json,
    );
  }

  static List<MastodonStatusModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MastodonStatusModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  List<String> replyMentions() {
    // Uses the direct 'acct' field from this status model first.
    final mainAcct = (this.acct.isNotEmpty) ? "@${this.acct}" : "@${this.account.username}";
    return [mainAcct, ...mentions.map((mention) => '@${mention.acct}').toList()];
  }
}

class MastodonStatusMentionModel {
  final String id;
  final String acct;
  final String username;
  final String url; // Kept 'url' as sample data showed it.

  MastodonStatusMentionModel({
    required this.id,
    required this.acct,
    required this.username,
    required this.url,
  });

  factory MastodonStatusMentionModel.fromJson(Map<String, dynamic> json) {
    return MastodonStatusMentionModel(
      id: json['id'] as String,
      acct: json['acct'] as String,
      username: json['username'] as String,
      url: json['url'] as String,
    );
  }

  static List<MastodonStatusMentionModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MastodonStatusMentionModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}

