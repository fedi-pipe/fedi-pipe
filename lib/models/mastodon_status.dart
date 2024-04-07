class MastodonStatus {
  String id;
  String content;
  String url;
  String visibility;
  String createdAt;
  String accountDisplayName;
  String accountAvatarUrl;

  MastodonStatus({
    required this.id,
    required this.content,
    required this.url,
    required this.visibility,
    required this.createdAt,
    required this.accountDisplayName,
    required this.accountAvatarUrl,
  });

  factory MastodonStatus.fromJson(Map<String, dynamic> json) {
    return MastodonStatus(
      id: json['id'],
      content: json['content'],
      url: json['url'],
      visibility: json['visibility'],
      createdAt: json['created_at'],
      accountDisplayName: json['account']['display_name'],
      accountAvatarUrl: json['account']['avatar'],
    );
  }
}
