import 'package:fedi_pipe/models/mastodon_status.dart';

/// Holds the surrounding conversation for a status.
/// Returned by GET /api/v1/statuses/:id/context.
class StatusContextModel {
  const StatusContextModel({
    required this.ancestors,
    required this.descendants,
  });

  final List<MastodonStatusModel> ancestors;
  final List<MastodonStatusModel> descendants;

  factory StatusContextModel.fromJson(Map<String, dynamic> json) {
    return StatusContextModel(
      ancestors: (json['ancestors'] as List<dynamic>)
          .map((e) => MastodonStatusModel.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      descendants: (json['descendants'] as List<dynamic>)
          .map((e) => MastodonStatusModel.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
