import 'package:equatable/equatable.dart';

import '../../core/constants/api_constants.dart';

class WatchProviderModel extends Equatable {
  final int id;
  final String name;
  final String? logoPath;

  const WatchProviderModel({
    required this.id,
    required this.name,
    this.logoPath,
  });

  factory WatchProviderModel.fromJson(Map<String, dynamic> json) {
    return WatchProviderModel(
      id: json['provider_id'] as int? ?? 0,
      name: json['provider_name'] as String? ?? '',
      logoPath: json['logo_path'] as String?,
    );
  }

  String get logoUrl {
    if (logoPath == null || logoPath!.isEmpty) return '';
    return '${ApiConstants.imageBaseUrl}w92$logoPath';
  }

  @override
  List<Object?> get props => [id, name, logoPath];
}

class WatchProvidersResult extends Equatable {
  final List<WatchProviderModel> flatrate; // streaming (Netflix, Prime...)
  final List<WatchProviderModel> rent;
  final List<WatchProviderModel> buy;
  final String? link;

  const WatchProvidersResult({
    this.flatrate = const [],
    this.rent = const [],
    this.buy = const [],
    this.link,
  });

  factory WatchProvidersResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WatchProvidersResult();

    List<WatchProviderModel> parseList(String key) {
      final list = json[key] as List<dynamic>? ?? [];
      return list
          .map((e) => WatchProviderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return WatchProvidersResult(
      flatrate: parseList('flatrate'),
      rent: parseList('rent'),
      buy: parseList('buy'),
      link: json['link'] as String?,
    );
  }

  bool get isEmpty => flatrate.isEmpty && rent.isEmpty && buy.isEmpty;

  @override
  List<Object?> get props => [flatrate, rent, buy, link];
}
