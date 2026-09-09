import 'package:equatable/equatable.dart';

class VideoModel extends Equatable {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;

  const VideoModel({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? 'Trailer',
      site: json['site'] as String? ?? '',
      type: json['type'] as String? ?? '',
      official: json['official'] as bool? ?? false,
    );
  }

  /// URL do YouTube
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';

  /// Thumbnail do YouTube
  String get thumbnailUrl => 'https://img.youtube.com/vi/$key/hqdefault.jpg';

  bool get isTrailer => type.toLowerCase() == 'trailer';
  bool get isYoutube => site.toLowerCase() == 'youtube';

  @override
  List<Object?> get props => [id, key, name, site, type, official];
}
